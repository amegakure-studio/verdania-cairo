fn convert_position_to_idx(width: u64, x: u64, y: u64) -> u64 {
    (y * width) + x
}

fn convert_idx_to_position(width: u64, idx: u64) -> (u64, u64) {
    let (q, r) = integer::u64_safe_divmod(idx, integer::u64_as_non_zero(width));
    (r, q)
}