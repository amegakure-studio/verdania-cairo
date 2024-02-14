use verdania::pathfinding::numbers::i64::i64;
use verdania::pathfinding::numbers::integer_trait::IntegerTrait;
use verdania::pathfinding::utils::map_utils::{convert_position_to_idx, convert_idx_to_position};

struct Movement {
    horizontal: felt252,
    vertical: felt252
}

enum MovementType {
    Diagonal,
    Horizontal,
    Vertical
}

fn get_movement_type(movement: Movement) -> MovementType {
    assert(
        movement.horizontal == -1 || movement.horizontal == 0 || movement.horizontal == 1,
        'wrong horizontal movement'
    );
    assert(
        movement.vertical == -1 || movement.vertical == 0 || movement.vertical == 1,
        'wrong vertical movement'
    );

    if movement.horizontal != 0 && movement.vertical != 0 {
        MovementType::Diagonal
    } else if movement.horizontal != 0 {
        MovementType::Horizontal
    } else if movement.vertical != 0 {
        MovementType::Vertical
    } else {
        panic_with_felt252('wrong movement')
    }
}

fn get_movement_direction(node_grid: u64, parent_grid: u64, width: u64) -> (i64, i64) {
    let (x, y) = convert_idx_to_position(width, node_grid);
    let (px, py) = convert_idx_to_position(width, parent_grid);

    get_movement_direction_coords(x, y, px, py)
}

fn get_movement_direction_coords(x: u64, y: u64, px: u64, py: u64) -> (i64, i64) {
    let dx = if x > px {
        IntegerTrait::<i64>::new(1, false)
    } else if x < px {
        IntegerTrait::<i64>::new(1, true)
    } else {
        Zeroable::zero()
    };

    let dy = if y > py {
        IntegerTrait::<i64>::new(1, false)
    } else if y < py {
        IntegerTrait::<i64>::new(1, true)
    } else {
        Zeroable::zero()
    };

    (dx, dy)
}
