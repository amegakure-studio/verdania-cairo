// fn octile(distance_x: u64, distance_y: u64) -> u64 {
//     let SQRT2 = starknet::u64_sqrt(2);
//     if (is_le(distance_x, distance_y + 1) == 1) {
//         return (SQRT2 - 1) * distance_x + distance_y;
//     } else {
//         return (SQRT2 - 1) * distance_y + distance_x;
//     }
// }

fn manhattan(distance_x: u64, distance_y: u64) -> u64 {
    distance_x + distance_y
}

