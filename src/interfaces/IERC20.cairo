use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TState> {
    fn init(ref self: TState, name: felt252, symbol: felt252, initial_supply: u64);
    fn mint(ref self: TState, recipient: ContractAddress, amount: u64);
    fn total_supply(self: @TState) -> u64;
    fn balance_of(self: @TState, account: ContractAddress) -> u64;
    fn allowance(self: @TState, owner: ContractAddress, spender: ContractAddress) -> u64;
    fn transfer(ref self: TState, recipient: ContractAddress, amount: u64) -> bool;
    fn transfer_from(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u64
    ) -> bool;
    fn approve(ref self: TState, spender: ContractAddress, amount: u64) -> bool;
}

#[starknet::interface]
trait IERC20Metadata<TState> {
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn decimals(self: @TState) -> u8;
}

#[starknet::interface]
trait ISafeAllowance<TState> {
    fn increase_allowance(ref self: TState, spender: ContractAddress, added_value: u64) -> bool;
    fn decrease_allowance(
        ref self: TState, spender: ContractAddress, subtracted_value: u64
    ) -> bool;
}

#[starknet::interface]
trait IERC20Camel<TState> {
    fn totalSupply(self: @TState) -> u64;
    fn balanceOf(self: @TState, account: ContractAddress) -> u64;
    fn allowance(self: @TState, owner: ContractAddress, spender: ContractAddress) -> u64;
    fn transfer(ref self: TState, recipient: ContractAddress, amount: u64) -> bool;
    fn transferFrom(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u64
    ) -> bool;
    fn approve(ref self: TState, spender: ContractAddress, amount: u64) -> bool;
}

#[starknet::interface]
trait IERC20CamelOnly<TState> {
    fn totalSupply(self: @TState) -> u64;
    fn balanceOf(self: @TState, account: ContractAddress) -> u64;
    fn transferFrom(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u64
    ) -> bool;
}

#[starknet::interface]
trait ISafeAllowanceCamel<TState> {
    fn increaseAllowance(ref self: TState, spender: ContractAddress, addedValue: u64) -> bool;
    fn decreaseAllowance(ref self: TState, spender: ContractAddress, subtractedValue: u64) -> bool;
}

#[starknet::interface]
trait ERC20ABI<TState> {
    // IERC20
    fn total_supply(self: @TState) -> u64;
    fn balance_of(self: @TState, account: ContractAddress) -> u64;
    fn allowance(self: @TState, owner: ContractAddress, spender: ContractAddress) -> u64;
    fn transfer(ref self: TState, recipient: ContractAddress, amount: u64) -> bool;
    fn transfer_from(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u64
    ) -> bool;
    fn approve(ref self: TState, spender: ContractAddress, amount: u64) -> bool;

    // IERC20Metadata
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn decimals(self: @TState) -> u8;

    // IERC20SafeAllowance
    fn increase_allowance(ref self: TState, spender: ContractAddress, added_value: u64) -> bool;
    fn decrease_allowance(
        ref self: TState, spender: ContractAddress, subtracted_value: u64
    ) -> bool;

    // IERC20CamelOnly
    fn totalSupply(self: @TState) -> u64;
    fn balanceOf(self: @TState, account: ContractAddress) -> u64;
    fn transferFrom(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u64
    ) -> bool;

    // IERC20CamelSafeAllowance
    fn increaseAllowance(ref self: TState, spender: ContractAddress, addedValue: u64) -> bool;
    fn decreaseAllowance(ref self: TState, spender: ContractAddress, subtractedValue: u64) -> bool;
}
