use starknet::ContractAddress;

#[starknet::interface]
trait IERC1155<TState> {
    fn init(ref self: TState);
    fn mint(ref self: TState, to: ContractAddress, id: u64, amount: u64);
    fn balance_of(self: @TState, account: ContractAddress, id: u64) -> u64;
    fn balance_of_batch(
        self: @TState, accounts: Array<ContractAddress>, ids: Array<u64>
    ) -> Array<u64>;
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    fn is_approved_for_all(
        self: @TState, account: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        id: u64,
        amount: u64,
        data: Array<u8>
    );
    fn safe_batch_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        ids: Array<u64>,
        amounts: Array<u64>,
        data: Array<u8>
    );
}

#[starknet::interface]
trait IERC1155CamelOnly<TState> {
    fn balanceOf(self: @TState, account: ContractAddress, id: u64) -> u64;
    fn balanceOfBatch(
        self: @TState, accounts: Array<ContractAddress>, ids: Array<u64>
    ) -> Array<u64>;
    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);
    fn isApprovedForAll(self: @TState, account: ContractAddress, operator: ContractAddress) -> bool;
    fn safeTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        id: u64,
        amount: u64,
        data: Array<u8>
    );
    fn safeBatchTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        ids: Array<u64>,
        amounts: Array<u64>,
        data: Array<u8>
    );
}

#[starknet::interface]
trait IERC1155Metadata<TState> {
    fn owner(self: @TState) -> ContractAddress;
// fn name(self: @TState) -> felt252;
// fn symbol(self: @TState) -> felt252;
// fn uri(self: @TState, token_id: u64) -> felt252;
}

//
// ERC721 ABI
//

#[starknet::interface]
trait ERC1155ABI<TState> {
    // IERC1155
    fn balance_of(self: @TState, account: ContractAddress, id: u64) -> u64;
    fn balance_of_batch(
        self: @TState, accounts: Array<ContractAddress>, ids: Array<u64>
    ) -> Array<u64>;
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    fn is_approved_for_all(
        self: @TState, account: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        id: u64,
        amount: u64,
        data: Array<u8>
    );
    fn safe_batch_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        ids: Array<u64>,
        amounts: Array<u64>,
        data: Array<u8>
    );

    // IERC1155Metadata
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn uri(self: @TState, token_id: u64) -> felt252;

    // IERC1155CamelOnly
    fn balanceOf(self: @TState, account: ContractAddress, id: u64) -> u64;
    fn balanceOfBatch(
        self: @TState, accounts: Array<ContractAddress>, ids: Array<u64>
    ) -> Array<u64>;
    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);
    fn isApprovedForAll(self: @TState, account: ContractAddress, operator: ContractAddress) -> bool;
    fn safeTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        id: u64,
        amount: u64,
        data: Array<u8>
    );
    fn safeBatchTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        ids: Array<u64>,
        amounts: Array<u64>,
        data: Array<u8>
    );
}
