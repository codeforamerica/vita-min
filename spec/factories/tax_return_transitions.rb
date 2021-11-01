# == Schema Information
#
# Table name: tax_return_transitions
#
#  id            :bigint           not null, primary key
#  metadata      :jsonb
#  most_recent   :boolean          not null
#  sort_key      :integer          not null
#  to_state      :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tax_return_id :integer          not null
#
# Indexes
#
#  index_tax_return_transitions_parent_most_recent  (tax_return_id,most_recent) UNIQUE WHERE most_recent
#  index_tax_return_transitions_parent_sort         (tax_return_id,sort_key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tax_return_id => tax_returns.id)
#
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
