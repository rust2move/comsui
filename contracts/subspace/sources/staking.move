module subspace::staking {
    use sui::tx_context::TxContext;
    use sui::coin;
    use sui::balance::{Self, Balance};
    use sui::object::{Self, ID, UID};
    use sui::vec_map::{Self, VecMap};
    use sui::sui::SUI;
    use sui_system::staking_pool::StakedSui;
    use sui_system::sui_system::{Self, SuiSystemState};

    const EInsufficientBalance: u64 = 0;
    const EStakeObjectNonExistent: u64 = 1;

    struct LockedStake has key {
        id: UID,
        staked_sui: VecMap<ID, StakedSui>,
        sui: Balance<SUI>,
        locked_until_epoch: u64,
    }

    public fun new(locked_until_epoch: u64, ctx: &mut TxContext): LockedStake {
        LockedStake {
            id: object::new(ctx),
            staked_sui: vec_map::empty(),
            sui: balance::zero(),
            locked_until_epoch: epoch_time_lock::new(locked_until_epoch, ctx),
        }
    }

    public fun unlock(ls: LockedStake, ctx: &TxContext): (VecMap<ID, StakedSui>, Balance<SUI>) {
        let LockedStake { id, staked_sui, sui, locked_until_epoch } = ls;
        epoch_time_lock::destroy(locked_until_epoch, ctx);
        object::delete(id);
        (staked_sui, sui)
    }

    public fun deposit_staked_sui(ls: &mut LockedStake, staked_sui: StakedSui) {
        let id = object::id(&staked_sui);
        // This insertion can't abort since each object has a unique id.
        vec_map::insert(&mut ls.staked_sui, id, staked_sui);
    }

    public fun deposit_sui(ls: &mut LockedStake, sui: Balance<SUI>) {
        balance::join(&mut ls.sui, sui);
    }

    public fun stake(
        ls: &mut LockedStake,
        sui_system: &mut SuiSystemState,
        amount: u64,
        validator_address: address,
        ctx: &mut TxContext
    ) {
        assert!(balance::value(&ls.sui) >= amount, EInsufficientBalance);
        let stake = sui_system::request_add_stake_non_entry(
            sui_system,
            coin::from_balance(balance::split(&mut ls.sui, amount), ctx),
            validator_address,
            ctx
        );
        deposit_staked_sui(ls, stake);
    }

    public fun unstake(
        ls: &mut LockedStake,
        sui_system: &mut SuiSystemState,
        staked_sui_id: ID,
        ctx: &mut TxContext
    ): u64 {
        assert!(vec_map::contains(&ls.staked_sui, &staked_sui_id), EStakeObjectNonExistent);
        let (_, stake) = vec_map::remove(&mut ls.staked_sui, &staked_sui_id);
        let sui_balance = sui_system::request_withdraw_stake_non_entry(sui_system, stake, ctx);
        let amount = balance::value(&sui_balance);
        deposit_sui(ls, sui_balance);
        amount
    }

    // ============================= getters =============================

    public fun staked_sui(ls: &LockedStake): &VecMap<ID, StakedSui> {
        &ls.staked_sui
    }

    public fun sui_balance(ls: &LockedStake): u64 {
        balance::value(&ls.sui)
    }

    public fun locked_until_epoch(ls: &LockedStake): u64 {
        epoch_time_lock::epoch(&ls.locked_until_epoch)
    }
}
