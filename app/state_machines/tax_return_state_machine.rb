class TaxReturnStateMachine
  include Statesman::Machine

  state :intake_before_consent, initial: true
  state :intake_in_progress
  state :intake_ready
  state :intake_reviewing
  state :intake_ready_for_call
  state :intake_info_requested
  state :intake_greeter_info_requested
  state :intake_needs_doc_help

  state :prep_ready_for_prep
  state :prep_preparing
  state :prep_info_requested
  state :review_ready_for_qr
  state :review_reviewing
  state :review_ready_for_call
  state :review_signature_requested
  state :review_info_requested

  state :file_needs_review
  state :file_ready_to_file
  state :file_efiled
  state :file_mailed
  state :file_rejected
  state :file_accepted
  state :file_not_filing
  state :file_hold

  # Allow free transition from any state, to any state for now
  states.each do |state|
    transition from: state, to: states
  end

  after_transition(after_commit: true) do |tax_return, transition|
    tax_return.status = transition.to_state # save the integer version, too, for now.
    tax_return.save!
  end

  def advance_to(new_state)
    transition_to(new_state) if self.class.states.index(current_state) < self.class.states.index(new_state.to_s)
  end

  def previous_state
    previous_transition&.to_state || self.class.initial_state
  end

  def previous_transition
    history.where(most_recent: false).last
  end

  def last_changed_by
    last_transition&.initiated_by_user
  end
end
