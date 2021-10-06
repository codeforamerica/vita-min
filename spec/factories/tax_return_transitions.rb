FactoryBot.define do
  factory :tax_return_transition do
    tax_return
    most_recent { true }
    sort_key { 0 }
    to_state { "intake_not_ready" }
    TaxReturnStateMachine.states.each do |state|
      trait state.to_sym do
        to_state { state }
      end
    end
  end
end