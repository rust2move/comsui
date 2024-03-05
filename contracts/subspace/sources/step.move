module subspace::Vote {

    use Std::BCS;
    use Std::Errors;
    use Std::Event;
    use Std::Signer;
    use Std::Vector;
    #[test_only]
    friend ExperimentalFramework::VoteTests;

    struct BallotID has store, copy, drop {
        counter: u64,
        proposer: address,
    }

    struct WeightedVoter has store, copy, drop {
        weight: u64,
        voter: vector<u8>,
    }

    struct Ballot<Proposal: store + drop> has store, copy, drop {
        proposal: Proposal,
        proposal_type: vector<u8>,
        /// The num_votes_required for this proposal to be approved
        num_votes_required: u64,
        /// A vector of addresses which are allowed to vote on this ballot.
        allowed_voters: vector<WeightedVoter>,
        /// Votes received so far
        votes_received: vector<WeightedVoter>,
        /// Total number of weighted votes received
        total_weighted_votes_received: u64,
        // A globally unique ballot id that is created for every proposal
        ballot_id: BallotID,
        // Votes rejected after this time
        expiration_timestamp_secs: u64,
    }

    struct Ballots<Proposal: store + drop> has key {
        ballots: vector<Ballot<Proposal>>,
        create_ballot_handle: Event::EventHandle<CreateBallotEvent<Proposal>>,
        remove_ballot_handle: Event::EventHandle<RemoveBallotEvent>,
        voted_handle: Event::EventHandle<VotedEvent>,
        ballot_approved_handle: Event::EventHandle<BallotApprovedEvent>,
    }

    struct BallotCounter has key {
        counter: u64,
    }

    struct CreateBallotEvent<Proposal: store + drop> has drop, store {
        ballot_id: BallotID,
        ballot: Ballot<Proposal>,
    }

    struct RemoveBallotEvent has drop, store {
        ballot_id: BallotID,
    }

    struct VotedEvent has drop, store {
        ballot_id: BallotID,
        voter: address,
        vote_weight: u64,
    }

    struct BallotApprovedEvent has drop, store {
        ballot_id: BallotID,
    }

    const MAX_BALLOTS_PER_PROPOSAL_TYPE_PER_ADDRESS: u64 = 256;

    /// The provided timestamp(s) were invalid
    const EINVALID_TIMESTAMP: u64 = 1;
    /// The address already contains has the maximum of ballots allowed
    /// MAX_BALLOTS_PER_PROPOSAL_TYPE_PER_ADDRESS
    const ETOO_MANY_BALLOTS: u64 = 2;
    /// Ballot with the provided id was not found
    const EBALLOT_NOT_FOUND: u64 = 3;
    /// Proposal details in the vote do not match the proposal details
    /// in the ballot
    const EBALLOT_PROPOSAL_MISMATCH: u64 = 4;
    /// Voter not allowed to vote in the ballot
    const EINVALID_VOTER: u64 = 5;
    /// current timestamp > ballot expiration time
    const EBALLOT_EXPIRED: u64 = 7;
    /// Voter has already voted in this ballot
    const EALREADY_VOTED: u64 = 8;
    /// Num_votes must be greater than 0, so that election is not won when started
    const EINVALID_NUM_VOTES: u64 = 9;

    /// A constructor for BallotID
    public fun new_ballot_id(
        counter: u64,
        proposer: address,
    ): BallotID {
        BallotID {
            counter,
            proposer,
        }
    }

    /// A constructor for WeightedVoter
    public fun new_weighted_voter(
        weight: u64,
        voter: vector<u8>,
    ): WeightedVoter {
        WeightedVoter {
            weight,
            voter,
        }
    }

    /// Create a ballot under the signer's address and return the `BallotID`
    public fun create_ballot<Proposal: store + copy + drop>(
        ballot_account: &signer,
        proposal: Proposal,
        proposal_type: vector<u8>,
        num_votes_required: u64,
        allowed_voters: vector<WeightedVoter>,
        expiration_timestamp_secs: u64
    ): BallotID acquires Ballots, BallotCounter {
        let ballot_address = Signer::address_of(ballot_account);

        assert!(DiemTimestamp::now_seconds() < expiration_timestamp_secs, Errors::invalid_argument(EINVALID_TIMESTAMP));
        assert!(num_votes_required > 0, Errors::invalid_argument(EINVALID_NUM_VOTES));

        if (!exists<BallotCounter>(ballot_address)) {
            move_to(ballot_account, BallotCounter {
                counter: 0,
            });
        };
        if (!exists<Ballots<Proposal>>(ballot_address)) {
            move_to(ballot_account, Ballots<Proposal> {
                ballots: Vector::empty(),
                create_ballot_handle: Event::new_event_handle<CreateBallotEvent<Proposal>>(ballot_account),
                remove_ballot_handle: Event::new_event_handle<RemoveBallotEvent>(ballot_account),
                voted_handle: Event::new_event_handle<VotedEvent>(ballot_account),
                ballot_approved_handle: Event::new_event_handle<BallotApprovedEvent>(ballot_account),
            });
        };

        let ballot_data = borrow_global_mut<Ballots<Proposal>>(ballot_address);

        // Remove any expired ballots
        gc_internal<Proposal>(ballot_data);
        let ballots = &mut ballot_data.ballots;

        assert!(Vector::length(ballots) < MAX_BALLOTS_PER_PROPOSAL_TYPE_PER_ADDRESS, Errors::limit_exceeded(ETOO_MANY_BALLOTS));
        let ballot_id = new_ballot_id(incr_counter(ballot_account), ballot_address);
        let ballot = Ballot<Proposal> {
            proposal,
            proposal_type,
            num_votes_required,
            allowed_voters,
            votes_received: Vector::empty(),
            total_weighted_votes_received: 0,
            ballot_id: *&ballot_id,
            expiration_timestamp_secs,
        };
        Vector::push_back(ballots, *&ballot);
        Event::emit_event<CreateBallotEvent<Proposal>>(
            &mut ballot_data.create_ballot_handle,
            CreateBallotEvent {
                ballot_id: *&ballot_id,
                ballot,
            },
        );
        ballot_id
    }

    // Checks if a voter is present in the vector<WeightedVoter>
    fun check_voter_present(
        weighted_voters: &vector<WeightedVoter>,
        voter: &vector<u8>,
    ): bool {
        let i = 0;
        let len = Vector::length(weighted_voters);
        while (i < len) {
            if (&Vector::borrow(weighted_voters, i).voter == voter) return true;
            i = i + 1;
        };
        false
    }


    public fun vote<Proposal: store + drop>(
        voter_account: &signer,
        ballot_id: BallotID,
        proposal_type: vector<u8>,
        proposal: Proposal,
    ): bool acquires Ballots {
        let ballot_data = borrow_global_mut<Ballots<Proposal>>(ballot_id.proposer);

        // Remove any expired ballots
        gc_internal<Proposal>(ballot_data);

        let ballots = &mut ballot_data.ballots;
        let i = 0;
        let len = Vector::length(ballots);
        while (i < len) {
            if (&Vector::borrow(ballots, i).ballot_id == &ballot_id) break;
            i = i + 1;
        };
        assert!(i < len, Errors::invalid_state(EBALLOT_NOT_FOUND));
        let ballot_index = i;
        let ballot = Vector::borrow_mut(ballots, ballot_index);

        assert!(&ballot.proposal == &proposal, Errors::invalid_argument(EBALLOT_PROPOSAL_MISMATCH));
        assert!(&ballot.proposal_type == &proposal_type, Errors::invalid_argument(EBALLOT_PROPOSAL_MISMATCH));

        let voter_address = Signer::address_of(voter_account);
        let voter_address_bcs = BCS::to_bytes(&voter_address);
        let allowed_voters = &ballot.allowed_voters;

        assert!(check_voter_present(allowed_voters, &voter_address_bcs), Errors::invalid_state(EINVALID_VOTER));
        assert!(DiemTimestamp::now_seconds() <= ballot.expiration_timestamp_secs, Errors::invalid_state(EBALLOT_EXPIRED));

        assert!(!check_voter_present(&ballot.votes_received, &voter_address_bcs), Errors::invalid_state(EALREADY_VOTED));

        let i = 0;
        let len = Vector::length(allowed_voters);
        while (i < len) {
            let weighted_voter = Vector::borrow(allowed_voters, i);
            if (&weighted_voter.voter == &voter_address_bcs) {
                Vector::push_back(&mut ballot.votes_received, *weighted_voter);
                ballot.total_weighted_votes_received = ballot.total_weighted_votes_received + weighted_voter.weight;
                Event::emit_event<VotedEvent>(
                    &mut ballot_data.voted_handle,
                    VotedEvent {
                        ballot_id: *&ballot_id,
                        voter: voter_address,
                        vote_weight: weighted_voter.weight,
                    },
                );
                break
            };
            i = i + 1;
        };
        let ballot_approved = ballot.total_weighted_votes_received >= ballot.num_votes_required;
        // If the ballot gets approved, remove the ballot immediately
        if (ballot_approved) {
            Vector::swap_remove(ballots, ballot_index);
            Event::emit_event<BallotApprovedEvent>(
                &mut ballot_data.ballot_approved_handle,
                BallotApprovedEvent {
                    ballot_id,
                },
            );
        };
        ballot_approved
    }

    public(script) fun gc_ballots<Proposal: store + drop>(
        _signer: signer,
        addr: address,
    ) acquires Ballots {
        gc_internal<Proposal>(borrow_global_mut<Ballots<Proposal>>(addr));
    }

    public(friend) fun gc_test_helper<Proposal: store + drop>(
        addr: address,
    ): vector<BallotID>  acquires Ballots {
        gc_internal<Proposal>(borrow_global_mut<Ballots<Proposal>>(addr))
    }

    fun gc_internal<Proposal: store + drop>(
        ballot_data: &mut Ballots<Proposal>,
    ): vector<BallotID> {
        let ballots = &mut ballot_data.ballots;
        let remove_handle = &mut ballot_data.remove_ballot_handle;
        let i = 0;
        let removed_ballots = Vector::empty();
        while ({
            spec {
                invariant no_expired_ballots(ballots, DiemTimestamp::spec_now_seconds(), i);
                invariant vector_subset(ballots, old(ballot_data).ballots);
                invariant i <= len(ballots);
                invariant 0 <= i;
            };
            i < Vector::length(ballots)
        }) {
            let ballot = Vector::borrow(ballots, i);
            if (ballot.expiration_timestamp_secs < DiemTimestamp::now_seconds()) {
                let ballot_id = *(&ballot.ballot_id);
                Vector::swap_remove(ballots, i);
                Vector::push_back(&mut removed_ballots, *&ballot_id);
                Event::emit_event<RemoveBallotEvent>(
                    remove_handle,
                    RemoveBallotEvent {
                        ballot_id
                    },
                );
            } else {
                i = i + 1;
            };
        };
        removed_ballots
    }

    public(friend) fun remove_ballot_internal<Proposal: store + drop>(
        account: signer,
        ballot_id: BallotID,
    ) acquires Ballots {
        let addr = Signer::address_of(&account);
        let ballot_data = borrow_global_mut<Ballots<Proposal>>(addr);
        let ballots = &mut ballot_data.ballots;
        let remove_handle = &mut ballot_data.remove_ballot_handle;
        let i = 0;
        let len = Vector::length(ballots);
        while ({
            spec { invariant ballot_id_does_not_exist<Proposal>(ballot_id, ballots, i); };
            i < len
        }) {
            if (&Vector::borrow(ballots, i).ballot_id == &ballot_id) {
                Vector::swap_remove(ballots, i);
                Event::emit_event<RemoveBallotEvent>(
                    remove_handle,
                    RemoveBallotEvent {
                        ballot_id
                    },
                );
                return ()
            };
            i = i + 1;
        };
    }


    public fun remove_ballot<Proposal: store + drop>(
        account: signer,
        ballot_id: BallotID,
    ) acquires Ballots {
        remove_ballot_internal<Proposal>(account, ballot_id)
    }

    fun incr_counter(account: &signer): u64 acquires BallotCounter {
        let addr = Signer::address_of(account);
        let counter = &mut borrow_global_mut<BallotCounter>(addr).counter;
        let count = *counter;
        *counter = *counter + 1;
        count
    }


    spec module {
        /// Once the BallotCounter is published, it remains published forever
        invariant update forall ballot_addr: address where old(exists<BallotCounter>(ballot_addr)):
            exists<BallotCounter>(ballot_addr);

         /// Once a proposal is initialized, it stays initialized forever.
         invariant<Proposal> update forall ballot_addr: address
             where old(exists<Ballots<Proposal>>(ballot_addr)):
                 exists<Ballots<Proposal>>(ballot_addr);
    }


    spec fun ballot_counter_initialized_first<Proposal>(ballot_addr: address): bool {
        exists<Ballots<Proposal>>(ballot_addr) ==> exists<BallotCounter>(ballot_addr)
    }

    // UTILITY FUNCTIONS

    spec fun get_ballots<Proposal>(ballot_address: address): vector<Ballot<Proposal>> {
       global<Ballots<Proposal>>(ballot_address).ballots
    }

    /// Get the ballot matching ballot_id out of the ballots vector, if it is there.
    /// CAUTION: Returns a arbitrary value if it's not there.
    spec fun get_ballot<Proposal>(ballot_address: address, ballot_id: BallotID): Ballot<Proposal> {
         let ballots = global<Ballots<Proposal>>(ballot_address).ballots;
         get_ballots<Proposal>(ballot_address)[choose min i in 0..len(ballots) where ballots[i].ballot_id == ballot_id]
     }

    /// Tests whether ballot_id is represented in the ballots vector. Returns false if there is no
    /// ballots vector.
    spec fun ballot_exists<Proposal>(ballot_address: address, ballot_id: BallotID): bool {
        if (exists<Ballots<Proposal>>(ballot_address)) {
            let ballots = global<Ballots<Proposal>>(ballot_address).ballots;
            exists i in 0..len(ballots): ballots[i].ballot_id == ballot_id
        }
        else
            false
    }

    /// Assuming ballot exists, check if it's expired. Returns an arbitrary result if the
    /// ballot does not exist.
    /// NOTE: Maybe this should be "<=" not "<"
    spec fun is_expired_if_exists<Proposal>(ballot_address: address, ballot_id: BallotID): bool {
        get_ballot<Proposal>(ballot_address, ballot_id).expiration_timestamp_secs
            <= DiemTimestamp::spec_now_seconds()
    }

    // FUNCTIONS REPRESENTING STATES

    spec fun is_expired<Proposal>(ballot_address: address, ballot_id: BallotID): bool {
        ballot_exists<Proposal>(ballot_address, ballot_id)
        && is_expired_if_exists<Proposal>(ballot_address, ballot_id)
    }

    /// A BallotID is active state if it is in the ballots vector and not expired.
    spec fun is_active<Proposal>(ballot_address: address, ballot_id: BallotID): bool {
       ballot_exists<Proposal>(ballot_address, ballot_id)
       && !is_expired_if_exists<Proposal>(ballot_address, ballot_id)
    }

    spec create_ballot {
        /// create_ballot sets up a `Ballots<Proposal>` resource at the `ballot_account`
        /// address if one does not already exist.
        ensures exists<Ballots<Proposal>>(Signer::address_of(ballot_account));

        /// returns a new active `BallotID`.
        ensures is_active<Proposal>(Signer::address_of(ballot_account), result);
    }

    /// Returns "true" iff there are no ballots in v at indices less than i whose
    /// expiration time is less than or equal to the current time.
    spec fun no_expired_ballots<Proposal>(ballots: vector<Ballot<Proposal>>, now_seconds: u64, i: u64): bool {
        forall j in 0..i: ballots[j].expiration_timestamp_secs >= now_seconds
    }

    // This is equivalent to mapping each ballot in v to its ballot_id.
    // TODO: A map operation in the spec language would be much clearer.
    spec fun extract_ballot_ids<Proposal>(v: vector<Ballot<Proposal>>): vector<BallotID> {
        choose result: vector<BallotID> where len(result) == len(v)
        && (forall i in 0..len(v): result[i] == v[i].ballot_id)
    }

    /// Common post-conditions for `gc_internal` and `gc_ballots` (which just calls `gc_internal`)
    spec schema GcEnsures<Proposal> {
        ballot_data: Ballots<Proposal>;
        let pre_ballots = ballot_data.ballots;
        let post post_ballots = ballot_data.ballots;

        /// Ballots afterwards is a subset of ballots before.
        ensures vector_subset(post_ballots, pre_ballots);
        /// All expired ballots are removed
        ensures no_expired_ballots<Proposal>(post_ballots, DiemTimestamp::spec_now_seconds(), len(post_ballots));
    }

    spec gc_internal {
        pragma opaque;
        include GcEnsures<Proposal>;
        // Note: There is no specification of returned vector of removed ballot ids, because
        // return value seems not to be used.
    }

    spec gc_ballots {
        include GcEnsures<Proposal>{ballot_data: global<Ballots<Proposal>>(addr)};
    }

    // Lower-level invariants

    // helper functions

    spec fun ballot_ids_have_correct_ballot_address<Proposal>(proposer_address: address): bool {
       let ballots = get_ballots<Proposal>(proposer_address);
       forall i in 0..len(ballots): ballots[i].ballot_id.proposer == proposer_address
    }

    spec fun existing_ballots_have_small_counters<Proposal>(proposer_address: address): bool {
        // Just return true if there is no Ballots<Proposal> published at proposer_address
        // get_ballots may be undefined here, but we only use it when we know the Ballots
        // is published (in the next property.
        let ballots = get_ballots<Proposal>(proposer_address);
        exists<Ballots<Proposal>>(proposer_address)
        ==> (forall i in 0..len(ballots):
                ballots[i].ballot_id.counter < global<BallotCounter>(proposer_address).counter)
    }

     spec fun no_winning_ballots_in_vector<Proposal>(proposer_address: address): bool {
         let ballots = get_ballots<Proposal>(proposer_address);
         forall i in 0..len(ballots):
             ballots[i].total_weighted_votes_received < ballots[i].num_votes_required
     }

    spec module {
        /// ballots in vector all have the proposer address in their ballot IDs.
        invariant<Proposal> [suspendable] forall proposer_address: address:
            ballot_ids_have_correct_ballot_address<Proposal>(proposer_address);

        // AND of these two invariants works, but they don't if individual due to a bug.
        invariant<Proposal>
            (forall addr: address: existing_ballots_have_small_counters<Proposal>(addr))
            && (forall ballot_addr: address: ballot_counter_initialized_first<Proposal>(ballot_addr));

        invariant<Proposal> forall addr: address: no_winning_ballots_in_vector<Proposal>(addr);
    }

    /// There are no duplicate Ballot IDs in the Ballots<Proposer>.ballots vector
    spec fun unique_ballots<Proposal>(ballots: vector<Ballot<Proposal>>): bool {
        forall i in 0..len(ballots), j in 0..len(ballots):
            ballots[i].ballot_id == ballots[j].ballot_id ==> i == j
    }

    /// All `BallotID`s of `Ballot`s in a `Ballots.ballots` vector are unique.
    spec Ballots {
        invariant unique_ballots(ballots);
    }

    /// Asserts that ballot ID is not in ballots vector.  Used in loop invariant
    /// and post-condition of remove_ballot_internal
    spec fun ballot_id_does_not_exist<Proposal>(ballot_id: BallotID, ballots: vector<Ballot<Proposal>>, i: u64): bool {
        forall j in 0..i: ballots[j].ballot_id != ballot_id
    }

    spec remove_ballot_internal {
        let post ballots = get_ballots<Proposal>(Signer::address_of(account));
        ensures
            ballot_id_does_not_exist<Proposal>(ballot_id, ballots, len(ballots));
    }

    spec remove_ballot {
       let post ballots = get_ballots<Proposal>(Signer::address_of(account));
       ensures
           ballot_id_does_not_exist<Proposal>(ballot_id, ballots, len(ballots));
    }

    spec gc_test_helper {
        // Just a test function, we don't need to spec it.
        pragma verify = false;
    }

    // helper functions
    spec fun vector_subset<Elt>(v1: vector<Elt>, v2: vector<Elt>): bool {
        forall e in v1: exists i in 0..len(v2): v2[i] == e
    }
}