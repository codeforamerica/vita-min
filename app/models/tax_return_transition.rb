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
class TaxReturnTransition < ApplicationRecord
  belongs_to :tax_return, inverse_of: :tax_return_transitions

  after_destroy :update_most_recent, if: :most_recent?

  def initiated_by_user
    User.find(metadata["initiated_by_user_id"]) if metadata["initiated_by_user_id"].present?
  end

  private

  def update_most_recent
    last_transition = tax_return.tax_return_transitions.order(:sort_key).last
    return unless last_transition.present?

    last_transition.update_column(:most_recent, true)
  end
end
