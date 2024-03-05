module subspace::module {
    use sui::object::{Self, UID};
    use sui::object_bag::{Self, ObjectBag};
    use sui::coin::TreasuryCap;

    struct Treasury has store {
        treasuries: ObjectBag
    }

    public(friend) fun add_treasury_cap<T>(self: &mut Treasury, treasury_cap: TreasuryCap<T>) {
        let type = type_name::get<T>();
        object_bag::add(&mut self.treasuries, type, treasury_cap)
    }

    public(friend) fun create(ctx: &mut TxContext): Treasury {
        Treasury {
            treasuries: object_bag::new(ctx)
        }
    }

    public(friend) fun burn<T>(self: &mut Treasury, token: Coin<T>, ctx: &TxContext) {
    // public(friend) fun burn<T>(self: &mut Treasury, token: Coin<T>, ctx: &mut TxContext) {
        create_treasury_if_not_exist<T>(self, ctx);
        let treasury = object_bag::borrow_mut(&mut self.treasuries, type_name::get<T>());
        coin::burn(treasury, token);
    }

    public(friend) fun mint<T>(self: &mut Treasury, amount: u64, ctx: &mut TxContext): Coin<T> {
        create_treasury_if_not_exist<T>(self, ctx);
        let treasury = object_bag::borrow_mut(&mut self.treasuries, type_name::get<T>());
        coin::mint(treasury, amount, ctx)
    }

    // fun create_treasury_if_not_exist<T>(self: &mut Treasury, ctx: &mut TxContext) {
    fun create_treasury_if_not_exist<T>(self: &Treasury, _ctx: &TxContext) {
        let type = type_name::get<T>();
        if (!object_bag::contains(&self.treasuries, type)) {
            // // Lazily create currency if not exists
            // if (type == type_name::get<BTC>()) {
            //     object_bag::add(&mut self.treasuries, type, btc::create(ctx));
            // } else if (type == type_name::get<ETH>()) {
            //     object_bag::add(&mut self.treasuries, type, eth::create(ctx));
            // } else if (type == type_name::get<USDC>()) {
            //     object_bag::add(&mut self.treasuries, type, usdc::create(ctx));
            // } else if (type == type_name::get<USDT>()) {
            //     object_bag::add(&mut self.treasuries, type, usdt::create(ctx));
            // } else {
                abort EUnsupportedTokenType
            // };
        };
    }
}