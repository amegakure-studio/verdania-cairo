use core::option::OptionTrait;
use nullable::{Nullable, NullableTrait, null};
use verdania::pathfinding::utils::map_utils::{convert_position_to_idx, convert_idx_to_position};

//! Minimum Heap
const GV_KEY: felt252 = 'GV_KEY';

struct MinHeap<T> {
    heap: Felt252Dict<Nullable<(T, T)>>,
    len: u32
}

impl DestructMinHeap<T, +Drop<T>, +Felt252DictValue<T>> of Destruct<MinHeap<T>> {
    fn destruct(self: MinHeap<T>) nopanic {
        self.heap.squash();
    }
}

trait MinHeapTrait<T> {
    fn new() -> MinHeap<T>;
    fn add(ref self: MinHeap<T>, grid_id: T, value: T);
    fn poll(ref self: MinHeap<T>) -> Option::<(T, T)>;
    fn heapify_up(ref self: MinHeap<T>, heap_idx: u32);
    fn heapify_down(ref self: MinHeap<T>, heap_idx: u32, len: u32);
    fn swap(ref self: MinHeap<T>, idx_a: u32, idx_b: u32);

    fn left_child(ref self: MinHeap<T>, parent_idx: u32) -> Option<(T, T)>;
    fn right_child(ref self: MinHeap<T>, parent_idx: u32) -> Option<(T, T)>;
    fn get_smallest_child_idx(ref self: MinHeap<T>, idx: u32) -> u32;
// fn print(ref self: MinHeap<T>, width: u64);
}

impl MinHeapImpl<
    T,
    +Copy<T>,
    +Zeroable<T>,
    +Drop<T>,
    +PartialOrd<T>,
    +PartialEq<T>,
    +Felt252DictValue<T>,
    +Into<T, felt252>,
    +Into<T, u64>
> of MinHeapTrait<T> {
    fn new() -> MinHeap<T> {
        MinHeap { heap: Default::default(), len: Zeroable::zero() }
    }

    fn add(ref self: MinHeap<T>, grid_id: T, value: T) {
        self.heap.insert(self.len.into(), NullableTrait::new((grid_id, value)));
        self.heapify_up(self.len);
        self.len += 1;
    }

    fn heapify_up(ref self: MinHeap<T>, heap_idx: u32) {
        if heap_idx.is_zero() {
            return;
        }
        let (grid_id, grid_value) = self.heap.get(heap_idx.into()).deref();

        let parent_idx = get_parent_idx(heap_idx);
        if parent_idx.is_none() {
            return;
        }
        let (parent_id, parent_value) = self.heap.get(parent_idx.unwrap().into()).deref();

        if parent_value <= grid_value {
            return;
        }
        self.heap.insert(heap_idx.into(), NullableTrait::new((parent_id, parent_value)));
        self.heap.insert(parent_idx.unwrap().into(), NullableTrait::new((grid_id, grid_value)));

        self.heapify_up(parent_idx.unwrap());
    }

    fn poll(ref self: MinHeap<T>) -> Option::<(T, T)> {
        if self.len.is_zero() {
            return Option::None(());
        }
        let (start_grid_id, start_grid_value) = self.heap.get(0).deref();
        let (end_grid_id, end_grid_value) = self.heap.get((self.len - 1).into()).deref();

        self.heap.insert((self.len - 1).into(), null());
        self.len -= 1;

        if self.len > 0 {
            self.heap.insert(0, NullableTrait::new((end_grid_id, end_grid_value)));
            self.heapify_down(0, self.len);
        }
        Option::Some((start_grid_id, start_grid_value))
    }

    fn heapify_down(ref self: MinHeap<T>, heap_idx: u32, len: u32) {
        if !has_left_child(heap_idx, @len) {
            return;
        }
        let (grid_id, grid_value) = self.heap.get(heap_idx.into()).deref();

        let smallest_child_idx = self.get_smallest_child_idx(heap_idx);
        let (sc_grid_id, sc_value) = self.heap.get(smallest_child_idx.into()).deref();

        if grid_value < sc_value {
            return;
        } else {
            self.swap(heap_idx, smallest_child_idx);
        }
        self.heapify_down(smallest_child_idx, len);
    }

    fn get_smallest_child_idx(ref self: MinHeap<T>, idx: u32) -> u32 {
        let left_child_idx = get_left_child_idx(idx);
        let (lc_grid_id, lc_value) = self.heap.get(left_child_idx.into()).deref();

        if has_right_child(idx, @self.len) {
            let right_child_idx = get_right_child_idx(idx);
            let (rc_grid_id, rc_value) = self.heap.get(right_child_idx.into()).deref();

            if rc_value < lc_value {
                return right_child_idx;
            }
        }
        return left_child_idx;
    }

    fn swap(ref self: MinHeap<T>, idx_a: u32, idx_b: u32) {
        let (a_grid_id, a_grid_value) = self.heap.get(idx_a.into()).deref();
        let (b_grid_id, b_grid_value) = self.heap.get(idx_b.into()).deref();
        self.heap.insert(idx_a.into(), NullableTrait::new((b_grid_id, b_grid_value)));
        self.heap.insert(idx_b.into(), NullableTrait::new((a_grid_id, a_grid_value)));
    }

    fn left_child(ref self: MinHeap<T>, parent_idx: u32) -> Option<(T, T)> {
        let nullable_lc = self.heap.get(get_left_child_idx(parent_idx).into());
        if !nullable_lc.is_null() {
            let (id, value) = nullable_lc.deref();
            Option::Some((id, value))
        } else {
            Option::None(())
        }
    }

    fn right_child(ref self: MinHeap<T>, parent_idx: u32) -> Option<(T, T)> {
        let nullable_rc = self.heap.get(get_right_child_idx(parent_idx).into());
        if !nullable_rc.is_null() {
            let (id, value) = nullable_rc.deref();
            Option::Some((id, value))
        } else {
            Option::None(())
        }
    }
// fn print(ref self: MinHeap<T>, width: u64) {
//     let mut i = 0;
//     print!("Heap: {{ len: {}, values: [", self.len);
//     loop {
//         if i == self.len {
//             break;
//         }
//         let (id, value) = self.heap.get(i.into()).deref();
//         let id_felt: felt252 = id.into();
//         let value_felt: felt252 = value.into();
//         let (x, y) = convert_idx_to_position(width, id.into());
//         print!(" pos {}, (id: {}, ({}, {}), g: {}),", i, id_felt, x, y, value_felt);
//         i += 1;
//     };
//     println!(" ] }}")
// }
}

// AUX METHODS
fn get_parent_idx(child_idx: u32) -> Option<u32> {
    if (child_idx.is_zero()) {
        Option::None(())
    } else {
        Option::Some((child_idx - 1) / 2)
    }
}

fn get_left_child_idx(parent_idx: u32) -> u32 {
    2 * parent_idx + 1
}

fn get_right_child_idx(parent_idx: u32) -> u32 {
    2 * parent_idx + 2
}

fn has_left_child(idx: u32, heap_len: @u32) -> bool {
    let left_child_idx = get_left_child_idx(idx);
    left_child_idx < *heap_len
}

fn has_right_child(idx: u32, heap_len: @u32) -> bool {
    let right_child_idx = get_right_child_idx(idx);
    right_child_idx < *heap_len
}

fn has_parent(idx: u32) -> bool {
    get_parent_idx(idx).is_some()
}
