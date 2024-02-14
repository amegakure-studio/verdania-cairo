#[starknet::interface]
trait IJPS_system<TContractState> {
    fn find_path(self: @TContractState, start: (u64, u64), goal: (u64, u64)) -> Span<(u64, u64)>;
}

#[dojo::contract]
mod JPS_system {

    use super::IJPS_system;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::store::{Store, StoreTrait};

    use core::array::SpanTrait;
    use core::dict::Felt252DictTrait;
    use core::nullable::{Nullable, NullableTrait};
    use core::option::OptionTrait;
    use verdania::pathfinding::data_structures::{
        tile_info::{TilesInfo, TilesInfoTrait, InfoKey},
        min_heap::{MinHeap, MinHeapTrait},
    };
    use verdania::pathfinding::numbers::i64::i64;
    use verdania::pathfinding::numbers::integer_trait::IntegerTrait;
    use verdania::pathfinding::utils::constants::{
        PARENT_KEY, STATUS_KEY, DISTANCE_KEY, DISTANCE_TO_GOAL_KEY, ESTIMATED_TOTAL_PATH_DISTANCE_KEY, MAP_WIDTH
    };
    use verdania::pathfinding::utils::heuristics::manhattan;
    use verdania::pathfinding::utils::movement::get_movement_direction_coords;
    use verdania::pathfinding::utils::map_utils::{convert_position_to_idx, convert_idx_to_position};
    use verdania::constants::MAP_1_ID;

    const OPENED: u64 = 1;
    const CLOSED: u64 = 2;

    #[abi(embed_v0)]
    impl JPSSystem of IJPS_system<ContractState> {

        fn find_path(self: @ContractState, start: (u64, u64), goal: (u64, u64)) -> Span<(u64, u64)> {

            let mut store: Store = StoreTrait::new(self.world_dispatcher.read());

            let (sx, sy) = start;
            let (gx, gy) = goal;
            let mut tiles_info = TilesInfoTrait::new();
            let mut open_list: MinHeap<u64> = MinHeapTrait::new();

            let goal_id = convert_position_to_idx(MAP_WIDTH, gx, gy);
            let start_id = convert_position_to_idx(MAP_WIDTH, sx, sy);
            tiles_info.write(start_id, InfoKey::STATUS, OPENED);
            tiles_info.write(start_id, InfoKey::ESTIMATIVE_TOTAL_COST, 0);
            tiles_info.write(start_id, InfoKey::CUMULATIVE_PATH_DISTANCE, 0);
            open_list.add(start_id, 0);

            let mut goal_flag = false;
            let mut node_id_flag = 0;
            loop {
                if open_list.len == 0 || goal_flag {
                    break;
                }
                let (node_id, node_value) = open_list.poll().unwrap();
                let (node_x, node_y) = convert_idx_to_position(MAP_WIDTH, node_id);
                tiles_info.write(node_id, InfoKey::STATUS, CLOSED);

                if goal_id == node_id {
                    goal_flag = true;
                    node_id_flag = node_id;
                    break;
                }
                identify_successors(
                    ref store, ref tiles_info, ref open_list, node_id, node_x, node_y, gx, gy
                );
            };

            if goal_flag {
                let (node_x, node_y) = convert_idx_to_position(MAP_WIDTH, node_id_flag);
                return build_reverse_path_from(ref tiles_info, node_id_flag);
            } else {
                array![].span()
            }
        }
    }

    fn identify_successors(
        ref store: Store,
        ref tiles_info: TilesInfo,
        ref open_list: MinHeap<u64>,
        node_id: u64,
        node_x: u64,
        node_y: u64,
        goal_x: u64,
        goal_y: u64
    ) {
        let neighbours = get_neighbours(ref store, ref tiles_info, node_id);
        let mut i = 0;
        loop {
            if neighbours.len() == i {
                break;
            }
            let (nx, ny) = convert_idx_to_position(MAP_WIDTH, *neighbours.at(i));
            let opt_jump_point = jump(ref store, nx, ny, node_x, node_y, goal_x, goal_y);

            if opt_jump_point.is_some() {
                let jump_point = opt_jump_point.unwrap();
                let (jx, jy) = convert_idx_to_position(MAP_WIDTH, jump_point);
                let jp_status = tiles_info.read(jump_point, InfoKey::STATUS);
                if !jp_status.is_null() && jp_status.deref() == CLOSED {
                    i += 1;
                    continue;
                }

                let jd = manhattan(
                    (IntegerTrait::<i64>::new(jx, false) - IntegerTrait::<i64>::new(node_x, false)).mag,
                    (IntegerTrait::<i64>::new(jy, false) - IntegerTrait::<i64>::new(node_y, false)).mag
                );
                let ng = tiles_info.read(node_id, InfoKey::CUMULATIVE_PATH_DISTANCE).deref() + jd;

                let jp_g = tiles_info.read(jump_point, InfoKey::CUMULATIVE_PATH_DISTANCE);
                if jp_status.is_null()
                    || (!jp_status.is_null() && jp_status.deref() != OPENED)
                    || jp_g.is_null()
                    || (!jp_g.is_null() && ng < jp_g.deref()) {
                    tiles_info.write(jump_point, InfoKey::CUMULATIVE_PATH_DISTANCE, ng);

                    let jp_h = tiles_info.read(jump_point, InfoKey::DISTANCE_TO_GOAL);
                    if jp_h.is_null() {
                        let jp_h_estimated = manhattan(
                            (IntegerTrait::<i64>::new(jx, false)
                                - IntegerTrait::<i64>::new(goal_x, false))
                                .mag,
                            (IntegerTrait::<i64>::new(jy, false)
                                - IntegerTrait::<i64>::new(goal_y, false))
                                .mag
                        );
                        tiles_info.write(jump_point, InfoKey::DISTANCE_TO_GOAL, jp_h_estimated);
                    }
                    let jp_g = tiles_info.read(jump_point, InfoKey::CUMULATIVE_PATH_DISTANCE).deref();
                    let jp_f = jp_g + tiles_info.read(jump_point, InfoKey::DISTANCE_TO_GOAL).deref();

                    tiles_info.write(jump_point, InfoKey::ESTIMATIVE_TOTAL_COST, jp_f);
                    tiles_info.write(jump_point, InfoKey::PARENT, node_id);

                    if jp_status.is_null() || (!jp_status.is_null() && jp_status.deref() != OPENED) {
                        open_list.add(jump_point, jp_f);
                        tiles_info.write(jump_point, InfoKey::STATUS, OPENED);
                    }
                }
            }
            i += 1;
        }
    }

    fn jump(
        ref store: Store, x: u64, y: u64, parent_x: u64, parent_y: u64, goal_x: u64, goal_y: u64
    ) -> Option<u64> {
        let iy = IntegerTrait::<i64>::new(y, false);
        let ix = IntegerTrait::<i64>::new(x, false);
        let one = IntegerTrait::<i64>::new(1, false);
        let is_walkable = is_walkable_at(ref store, ix, iy);

        if !is_walkable {
            return Option::None(());
        }

        if x == goal_x && y == goal_y {
            return Option::Some(convert_position_to_idx(MAP_WIDTH, x, y));
        }
        let dx = ix - IntegerTrait::<i64>::new(parent_x, false);
        let dy = iy - IntegerTrait::<i64>::new(parent_y, false);
        if dx.is_non_zero() && dy.is_non_zero() {
            let p1 = is_walkable_at(ref store, ix - dx, iy + dy);
            let p2 = is_walkable_at(ref store, ix - dx, iy);
            let p3 = is_walkable_at(ref store, ix + dx, iy - dy);
            let p4 = is_walkable_at(ref store, ix, iy - dy);

            if (p1 && !p2) || (p3 && !p4) {
                return Option::Some(convert_position_to_idx(MAP_WIDTH, x, y));
            }

            if (jump(ref store, (ix + dx).mag, y, x, y, goal_x, goal_y).is_some()
                || jump(ref store, x, (iy + dy).mag, x, y, goal_x, goal_y).is_some()) {
                return Option::Some(convert_position_to_idx(MAP_WIDTH, x, y));
            }
        } else {
            if dx.is_non_zero() {
                let p1 = is_walkable_at(ref store, ix + dx, iy + one);
                let p2 = is_walkable_at(ref store, ix, iy + one);
                let p3 = is_walkable_at(ref store, ix + dx, iy - one);
                let p4 = is_walkable_at(ref store, ix, iy - one);

                if (p1 && !p2) || (p3 && !p4) {
                    return Option::Some(convert_position_to_idx(MAP_WIDTH, x, y));
                }
            } else {
                let p1 = is_walkable_at(ref store, ix + one, iy + dy);
                let p2 = is_walkable_at(ref store, ix + one, iy);
                let p3 = is_walkable_at(ref store, ix - one, iy + dy);
                let p4 = is_walkable_at(ref store, ix - one, iy);

                if (p1 && !p2) || (p3 && !p4) {
                    return Option::Some(convert_position_to_idx(MAP_WIDTH, x, y));
                }
            }
        }

        if is_walkable_at(ref store, ix + dx, iy) || is_walkable_at(ref store, ix, iy + dy) {
            return jump(ref store, (ix + dx).mag, (iy + dy).mag, x, y, goal_x, goal_y);
        } else {
            return Option::None(());
        }
    }

    fn build_reverse_path_from(ref tiles_info: TilesInfo, grid_id: u64) -> Span<(u64, u64)> {
        let (x, y) = convert_idx_to_position(MAP_WIDTH, grid_id);
        let mut res = array![grid_id];

        let mut parent_id = grid_id;
        loop {
            let p = tiles_info.read(parent_id, InfoKey::PARENT);
            if p.is_null() {
                break;
            }
            res.append(p.deref());
            parent_id = p.deref();
        };

        let mut i = res.len() - 1;
        let mut reverse = array![];
        loop {
            reverse.append(convert_idx_to_position(MAP_WIDTH, *res.at(i)));
            if i == 0 {
                break;
            }
            i -= 1;
        };
        reverse.span()
    }

    fn print_span(span: Span<u64>) {
        let mut i = 0;
        print!("Span: {{ values: [ ");
        loop {
            if span.len() == i {
                break;
            }
            if span.len() - 1 != i {
                print!("{}, ", *(span.at(i)));
            } else {
                print!("{}", *(span.at(i)));
            }
            i += 1;
        };
        println!(" ] }}")
    }

    fn get_neighbours(ref store: Store, ref tiles_info: TilesInfo, grid_id: u64) -> Span<u64> {
        let mut relevant_neighbours = array![];
        let parent_grid_id = tiles_info.read(grid_id, InfoKey::PARENT);

        if !parent_grid_id.is_null() {
            let (px, py) = convert_idx_to_position(MAP_WIDTH, parent_grid_id.deref());
            let (x, y) = convert_idx_to_position(MAP_WIDTH, grid_id);
            let (dx, dy) = get_movement_direction_coords(x, y, px, py);

            let ix = IntegerTrait::<i64>::new(x, false);
            let iy = IntegerTrait::<i64>::new(y, false);
            let one = IntegerTrait::<i64>::new(1, false);

            if dx.is_non_zero() && dy.is_non_zero() {
                if is_walkable_at(ref store, ix, iy + dy) {
                    relevant_neighbours
                        .append(convert_position_to_idx(MAP_WIDTH, x, (iy + dy).mag));
                }
                if is_walkable_at(ref store, ix + dx, iy) {
                    relevant_neighbours
                        .append(convert_position_to_idx(MAP_WIDTH, (ix + dx).mag, y));
                }
                if is_walkable_at(ref store, ix, iy + dy) || is_walkable_at(ref store, ix + dx, iy) {
                    relevant_neighbours
                        .append(convert_position_to_idx(MAP_WIDTH, (ix + dx).mag, (iy + dy).mag));
                }
                if !is_walkable_at(ref store, ix - dx, iy) && is_walkable_at(ref store, ix, iy + dy) {
                    relevant_neighbours
                        .append(convert_position_to_idx(MAP_WIDTH, (ix - dx).mag, (iy + dy).mag));
                }
                if !is_walkable_at(ref store, ix, iy - dy) && is_walkable_at(ref store, ix + dx, iy) {
                    relevant_neighbours
                        .append(convert_position_to_idx(MAP_WIDTH, (ix + dx).mag, (iy - dy).mag));
                }
            } else {
                if dx.is_zero() {
                    if is_walkable_at(ref store, ix, iy + dy) {
                        relevant_neighbours
                            .append(convert_position_to_idx(MAP_WIDTH, x, (iy + dy).mag));
                        if !is_walkable_at(ref store, ix + one, iy) {
                            relevant_neighbours
                                .append(convert_position_to_idx(MAP_WIDTH, x + 1, (iy + dy).mag));
                        }
                        if x != 0 && !is_walkable_at(ref store, ix - one, iy) {
                            relevant_neighbours
                                .append(convert_position_to_idx(MAP_WIDTH, x - 1, (iy + dy).mag));
                        }
                    }
                } else {
                    if is_walkable_at(ref store, ix + dx, iy) {
                        relevant_neighbours
                            .append(convert_position_to_idx(MAP_WIDTH, (ix + dx).mag, y));
                        if !is_walkable_at(ref store, ix, iy + one) {
                            relevant_neighbours
                                .append(convert_position_to_idx(MAP_WIDTH, (ix + dx).mag, y + 1));
                        }
                        if y != 0 && !is_walkable_at(ref store, ix, iy - one) {
                            relevant_neighbours
                                .append(convert_position_to_idx(MAP_WIDTH, (ix + dx).mag, y - 1));
                        }
                    }
                }
            }
        } else {
            let (x, y) = convert_idx_to_position(MAP_WIDTH, grid_id);
            return _get_neighbours(ref store, x, y);
        }
        relevant_neighbours.span()
    }

    fn _get_neighbours(ref store: Store, x: u64, y: u64) -> Span<u64> {
        let mut neighbours = array![];
        let mut s0 = false;
        let mut s1 = false;
        let mut s2 = false;
        let mut s3 = false;

        let iy = IntegerTrait::<i64>::new(y, false);
        let ix = IntegerTrait::<i64>::new(x, false);
        let one = IntegerTrait::<i64>::new(1, false);

        // ↑
        if is_walkable_at(ref store, ix, iy - one) {
            neighbours.append(convert_position_to_idx(MAP_WIDTH, x, y - 1));
            s0 = true;
        }

        // →
        if is_walkable_at(ref store, ix + one, iy) {
            neighbours.append(convert_position_to_idx(MAP_WIDTH, x + 1, y));
            s1 = true;
        }
        // ↓
        if is_walkable_at(ref store, ix, iy + one) {
            neighbours.append(convert_position_to_idx(MAP_WIDTH, x, y + 1));
            s2 = true;
        }
        // ←
        if is_walkable_at(ref store, ix - one, iy) {
            neighbours.append(convert_position_to_idx(MAP_WIDTH, x - 1, y));
            s3 = true;
        }

        let d0 = s3 || s0;
        let d1 = s0 || s1;
        let d2 = s1 || s2;
        let d3 = s2 || s3;

        // ↖
        if d0 && is_walkable_at(ref store, ix - one, iy - one) {
            neighbours.append(convert_position_to_idx(MAP_WIDTH, x - 1, y - 1));
        }
        // ↗
        if d1 && is_walkable_at(ref store, ix + one, iy - one) {
            neighbours.append(convert_position_to_idx(MAP_WIDTH, x + 1, y - 1));
        }
        // ↘
        if d2 && is_walkable_at(ref store, ix + one, iy + one) {
            neighbours.append(convert_position_to_idx(MAP_WIDTH, x + 1, y + 1));
        }
        // ↙
        if d3 && is_walkable_at(ref store, ix - one, iy + one) {
            neighbours.append(convert_position_to_idx(MAP_WIDTH, x - 1, y + 1));
        }
        neighbours.span()
    }

    fn is_walkable_at(ref store: Store, x: i64, y: i64) -> bool {
        let map = store.get_map(MAP_1_ID);
        let flag = is_inside(x, y, map.width, map.height);
        
        // TODO: farm_id
        let farm_id = 1;
        let tile_id = convert_position_to_idx(MAP_WIDTH, x.mag, y.mag);
        let tile_state = store.get_tile_state(farm_id, tile_id);
        // tile_state.entity_type == 0 return true

        if tile_state.entity_type == 0 {
            // terrain
            let tile = store.get_tile(farm_id, tile_id);
            // solo si son Grass, Sand
            true
        } else if tile_state.entity_type == 1 {
            // enviroment
            let env_entity = store.get_env_entity(tile_state.entity_type.into());
            // dependiendo el tipo de obstaculo si es caminable o no
            true
        } else {
            // si es un crop, siempre es caminable
            true
        }
    }

    fn is_inside(x: i64, y: i64, width: u64, height: u64) -> bool {
        if x.sign || y.sign {
            return false;
        }
        x.mag < width.into() && y.mag < height.into()
    }
}