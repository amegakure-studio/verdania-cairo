use starknet::ContractAddress;

#[starknet::interface]
trait IMarketplace<TContractState> {
    fn init(ref self: TContractState, erc20: ContractAddress, erc1155: ContractAddress);
    fn list_item(
        ref self: TContractState, id: u256, token_amount: u256, price: u256
    ) -> u256;
    fn buy_item(ref self: TContractState, item_id: u256, token_amount: u256);
}

#[dojo::contract]
mod Marketplace {
    use super::IMarketplace;
    use verdania::marketplace::models::{MarketplaceMeta, MarketplaceItem};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};

    use verdania::marketplace::erc1155::interface::{
        IERC1155DispatcherTrait, IERC1155Dispatcher
    };
    use verdania::marketplace::erc20::interface::{
        IERC20Dispatcher, IERC20DispatcherTrait
    };

    #[external(v0)]
    impl MarketplaceImpl of IMarketplace<ContractState> {

        fn init(ref self: ContractState, erc20: ContractAddress, erc1155: ContractAddress) {
            set!(
                self.world_dispatcher.read(), 
                MarketplaceMeta {
                        token: get_contract_address(),
                        erc20: erc20,
                        erc1155: erc1155,
                        current_item_len: 0
                }
            );
        }

        fn list_item(
            ref self: ContractState, id: u256, token_amount: u256, price: u256
        ) -> u256 {
            assert(token_amount > 0, 'Amount should be > 0');
            assert(price > 0, 'Price should be > 0');

            let mut marketplace_meta = get!(self.world_dispatcher.read(), get_contract_address(), MarketplaceMeta);

            IERC1155Dispatcher { contract_address: marketplace_meta.erc1155 }
                .safe_transfer_from(
                    from: get_caller_address(),
                    to: get_contract_address(),
                    id: id,
                    amount: token_amount,
                    data: array![]
                );

            let item_id = marketplace_meta.current_item_len;
            marketplace_meta.current_item_len += 1;
            set!(self.world_dispatcher.read(), (marketplace_meta));

            set!(self.world_dispatcher.read(), 
                MarketplaceItem {
                    id: item_id,
                    seller: get_caller_address(),
                    amount: token_amount,
                    remaining_amount: token_amount,
                    price
                }
            );
            item_id
        }

        fn buy_item(ref self: ContractState, item_id: u256, token_amount: u256) {
            
            let mut marketplace_meta = get!(self.world_dispatcher.read(), get_contract_address(), MarketplaceMeta);
            let mut item = get!(self.world_dispatcher.read(), item_id, MarketplaceItem);

            assert(token_amount <= item.remaining_amount, '');

            // let decimals = IERC20Dispatcher { contract_address: marketplace_meta.erc20 }.decimals();
            // let decimals = 0;

            let total_amount = item.price * token_amount;

            IERC20Dispatcher { contract_address: marketplace_meta.erc20 }
                .transfer_from(get_caller_address(), item.seller, total_amount);

            IERC1155Dispatcher { contract_address: marketplace_meta.erc1155 }
                .safe_transfer_from(
                    get_contract_address(),
                    get_caller_address(),
                    item.id,
                    token_amount,
                    array![]
                );

            item.remaining_amount = item.remaining_amount - token_amount;
            set!(self.world_dispatcher.read(), (item));
        }
    }
}