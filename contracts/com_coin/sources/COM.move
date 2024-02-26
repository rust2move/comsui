/// ComSui utility coin with a trusted manager responsible for minting/burning
module com_coin::COM {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct COM has drop {}

    fun init(witness: COM, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<COM>(
            witness,
            9,
            b"COM",
            b"COMSUI",
            b"commune-ai utility coin on SUI",
            option::none(),
            ctx
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx))
    }

    /// Manager can mint new coins
    public entry fun mint(
        treasury_cap: &mut TreasuryCap<COM>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    /// Manager can burn coins
    public entry fun burn(treasury_cap: &mut TreasuryCap<COM>, coin: Coin<COM>) {
        coin::burn(treasury_cap, coin);
    }
}
