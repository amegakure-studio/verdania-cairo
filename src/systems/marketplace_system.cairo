use starknet::ContractAddress;
use verdania::models::entities::marketplace::MarketplaceMeta;

#[starknet::interface]
trait IMarketplace<TContractState> {
    fn init(ref self: TContractState);
    fn update_meta(ref self: TContractState, marketplace_meta: MarketplaceMeta);
    fn list_item(
        ref self: TContractState, player: felt252, token_id: u64, token_amount: u64, price: u64
    ) -> u64;
    fn buy_item(ref self: TContractState, player: felt252, item_id: u64, token_amount: u64);
}

#[dojo::contract]
mod Marketplace {
    use super::IMarketplace;
    use verdania::models::entities::marketplace::{MarketplaceMeta, MarketplaceItem};
    use starknet::{ContractAddress, get_caller_address};

    use verdania::store::{Store, StoreTrait};

    use verdania::interfaces::IERC1155::{IERC1155DispatcherTrait, IERC1155Dispatcher};
    use verdania::interfaces::IERC20::{IERC20Dispatcher, IERC20DispatcherTrait};

    use verdania::constants::{ERC20_CONTRACT_ID, ERC1155_CONTRACT_ID, MARKETPLACE_CONTRACT_ID};

    #[external(v0)]
    impl MarketplaceImpl of IMarketplace<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            store
                .set_marketplace_meta(
                    MarketplaceMeta {
                        id: MARKETPLACE_CONTRACT_ID,
                        owner: get_caller_address(),
                        open: false,
                        spawn_time: 60000,
                        item_list_len: 0
                    }
                );
        }

        fn update_meta(ref self: ContractState, marketplace_meta: MarketplaceMeta) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let mut meta = store.get_marketplace_meta(MARKETPLACE_CONTRACT_ID);
            assert(get_caller_address() == meta.owner, 'Caller is not the owner');
            store.set_marketplace_meta(marketplace_meta);
        }

        fn list_item(
            ref self: ContractState, player: felt252, token_id: u64, token_amount: u64, price: u64
        ) -> u64 {
            assert(token_amount > 0, 'Amount should be > 0');
            assert(price > 0, 'Price should be > 0');

            let mut player: ContractAddress = player.try_into().unwrap();
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let mut marketplace_meta = store.get_marketplace_meta(MARKETPLACE_CONTRACT_ID);

            let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID);
            let marketplace = store.get_global_contract(MARKETPLACE_CONTRACT_ID);

            IERC1155Dispatcher { contract_address: erc1155.address }
                .safe_transfer_from(
                    from: player,
                    to: marketplace.address,
                    id: token_id,
                    amount: token_amount,
                    data: array![]
                );

            let item_id = marketplace_meta.item_list_len;
            marketplace_meta.item_list_len += 1;
            store.set_marketplace_meta(marketplace_meta);

            store
                .set_marketplace_item(
                    MarketplaceItem {
                        id: item_id,
                        token_id,
                        seller: player,
                        amount: token_amount,
                        remaining_amount: token_amount,
                        price
                    }
                );
            item_id
        }

        fn buy_item(ref self: ContractState, player: felt252, item_id: u64, token_amount: u64) {
            let mut player: ContractAddress = player.try_into().unwrap();
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let mut marketplace_meta = store.get_marketplace_meta(MARKETPLACE_CONTRACT_ID);
            let mut item = store.get_marketplace_item(item_id);

            assert(token_amount <= item.remaining_amount, '');

            let total_amount = item.price * token_amount;

            let erc20 = store.get_global_contract(ERC20_CONTRACT_ID);
            let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID);
            let marketplace = store.get_global_contract(MARKETPLACE_CONTRACT_ID);

            IERC20Dispatcher { contract_address: erc20.address }
                .transfer_from(player, item.seller, total_amount);

            IERC1155Dispatcher { contract_address: erc1155.address }
                .safe_transfer_from(
                    marketplace.address, player, item.token_id, token_amount, array![]
                );

            item.remaining_amount = item.remaining_amount - token_amount;
            store.set_marketplace_item(item);
        }
    }
}
