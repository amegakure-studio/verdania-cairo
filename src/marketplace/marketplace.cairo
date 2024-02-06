use starknet::ContractAddress;

#[starknet::interface]
trait IMarketplace<TContractState> {
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

    use verdania::store::{Store, StoreTrait};

    use verdania::marketplace::erc1155::interface::{
        IERC1155DispatcherTrait, IERC1155Dispatcher
    };
    use verdania::marketplace::erc20::interface::{
        IERC20Dispatcher, IERC20DispatcherTrait
    };

    use verdania::constants::{ERC20_CONTRACT_ID, ERC1155_CONTRACT_ID};

    #[external(v0)]
    impl MarketplaceImpl of IMarketplace<ContractState> {

        fn list_item(
            ref self: ContractState, id: u256, token_amount: u256, price: u256
        ) -> u256 {
            assert(token_amount > 0, 'Amount should be > 0');
            assert(price > 0, 'Price should be > 0');

            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);
            
            let mut marketplace_meta = store.get_marketplace_meta(get_contract_address());

            let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID); 
            IERC1155Dispatcher { contract_address: erc1155.address }
                .safe_transfer_from(
                    from: get_caller_address(),
                    to: get_contract_address(),
                    id: id,
                    amount: token_amount,
                    data: array![]
                );

            let item_id = marketplace_meta.current_item_len;
            marketplace_meta.current_item_len += 1;
            store.set_marketplace_meta(marketplace_meta);

            store.set_marketplace_item(
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

            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);
            
            let mut marketplace_meta = store.get_marketplace_meta(get_contract_address());
            let mut item = store.get_marketplace_item(item_id);

            assert(token_amount <= item.remaining_amount, '');

            // let decimals = IERC20Dispatcher { contract_address: marketplace_meta.erc20 }.decimals();
            // let decimals = 0;

            let total_amount = item.price * token_amount;

            let erc20 = store.get_global_contract(ERC20_CONTRACT_ID);
            let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID); 

            IERC20Dispatcher { contract_address: erc20.address }
                .transfer_from(get_caller_address(), item.seller, total_amount);

            IERC1155Dispatcher { contract_address: erc1155.address }
                .safe_transfer_from(
                    get_contract_address(),
                    get_caller_address(),
                    item.id,
                    token_amount,
                    array![]
                );

            item.remaining_amount = item.remaining_amount - token_amount;
            store.set_marketplace_item(item);
        }
    }
}