class TaxReturnStateMachine
  include Statesman::Machine

  state :intake_before_consent, initial: true
  state :intake_in_progress
  state :intake_needs_doc_help
  state :intake_info_requested
  state :intake_greeter_info_requested
  state :intake_ready
  state :intake_reviewing
  state :intake_ready_for_call

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
  state :file_fraud_hold

  # Allow free transition from any state, to any state for now
  states.each do |state|
    transition from: state, to: states
  end

  STATES_BY_STAGE = begin
                      stages = {}
                      statuses = states.without("intake_before_consent")
                      statuses.map do |status, _|
                        stage = status.to_s.split("_")[0]
                        stages[stage] = [] unless stages.key?(stage)
                        stages[stage].push(status)
                      end
                      stages
  end.freeze
  STAGES_BY_STATE = STATES_BY_STAGE.invert.each_with_object({}) do |(states, stage), hsh|
    states.each do |state|
      hsh[state] = stage
    end
  end.freeze

  STAGES = STATES_BY_STAGE.keys.freeze
  EXCLUDED_FROM_SLA = [:intake_before_consent, :file_accepted, :file_not_filing, :file_hold, :file_mailed].freeze
  # If you change the statuses included in capacity, you must also update the organization capacities sql view (organization_capacities_vXX.sql)
  EXCLUDED_FROM_CAPACITY = [:intake_before_consent, :intake_in_progress, :intake_greeter_info_requested, :intake_needs_doc_help, :file_mailed, :file_accepted, :file_not_filing, :file_hold, :file_fraud_hold].freeze
  INCLUDED_IN_CAPACITY = (states - EXCLUDED_FROM_CAPACITY).freeze
  FORWARD_TO_INTERCOM = [:file_accepted, :file_mailed, :file_not_filing].freeze
  INCLUDED_IN_PREVIOUS_YEAR_COMPLETED_INTAKES = [:prep_ready_for_prep, :prep_preparing, :review_ready_for_qr, :review_reviewing, :intake_ready_for_call, :review_signature_requested, :file_ready_to_file, :file_efiled, :file_accepted, :file_rejected].freeze

  ALLOWABLE_STATES_BY_ROLE = {
    GreeterRole::TYPE => {
      'intake' => [
        'intake_ready',
        'intake_greeter_info_requested',
        'intake_needs_doc_help'
      ],
      'file' => [
        'file_not_filing',
        'file_hold',
      ]
    }
  }

  after_transition(after_commit: true) do |tax_return, transition|
    tax_return.update_columns(current_state: transition.to_state)
    SearchIndexer.refresh_filterable_properties([tax_return.client_id])
    InteractionTrackingService.record_internal_interaction(tax_return.client) # manually run since the update_columns doesn't run callbacks
    if tax_return.client.intake
      MixpanelService.send_tax_return_event(tax_return, "status_change", { from_status: tax_return.previous_state })
    end
  end

  after_transition(to: "file_accepted") do |tax_return, _|
    MixpanelService.send_file_completed_event(tax_return, "filing_completed")
  end

  after_transition(to: "file_rejected") do |tax_return, _|
    MixpanelService.send_file_completed_event(tax_return, "filing_rejected")
  end

  after_transition(to: "file_not_filing") do |tax_return, _|
    MixpanelService.send_file_completed_event(tax_return, "not_filing")
  end

  after_transition(to: "file_mailed") do |tax_return, _|
    MixpanelService.send_tax_return_event(tax_return, "filing_filed", { filing_type: "mail" })
  end

  after_transition(to: "prep_ready_for_prep") do |tax_return, _|
    MixpanelService.send_tax_return_event(tax_return, "ready_for_prep")
  end

  after_transition(to: "file_efiled") do |tax_return, _|
    MixpanelService.send_tax_return_event(tax_return, "filing_filed", { filing_type: "efile" })
  end

  def advance_to(new_state)
    transition_to(new_state) if self.class.states.index(current_state) < self.class.states.index(new_state.to_s)
  end

  def previous_state
    previous_transition&.to_state || self.class.initial_state
  end

  def previous_transition
    history.reverse.find { |transition| !transition.most_recent }
  end

  def last_changed_by
    last_transition&.initiated_by_user
  end

  def self.available_states_for(role_type:)
    # TODO: Defaulting to 'all' for unknown roles feels bad
    ALLOWABLE_STATES_BY_ROLE.fetch(role_type, STATES_BY_STAGE)
  end

  def self.states_to_show_for_client_filter(role_type:)
    available_states = available_states_for(role_type:)
    excluded_states = ["file_fraud_hold", "file_needs_review"]
    available_states.transform_values { |states| states - excluded_states }
  end
end
