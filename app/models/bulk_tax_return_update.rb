# == Schema Information
#
# Table name: bulk_tax_return_updates
#
#  id                      :bigint           not null, primary key
#  data                    :json
#  state                   :string
#  status                  :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  assigned_user_id        :bigint
#  tax_return_selection_id :bigint           not null
#
# Indexes
#
#  index_btru_on_assigned_user_id         (assigned_user_id)
#  index_btru_on_tax_return_selection_id  (tax_return_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#
class BulkTaxReturnUpdate < ApplicationRecord
  has_one :user_notification, as: :notifiable
  belongs_to :tax_return_selection
  belongs_to :assigned_user, class_name: "User", optional: true

  enum status: TaxReturnStatus::STATUSES, _prefix: :status

  validate :data_stored_appropriately

  KEEP = "keep".freeze
  UPDATE = "update".freeze
  REMOVE = "remove".freeze
  DATA_ACTION_OPTIONS = [KEEP, UPDATE, REMOVE].freeze

  def data_stored_appropriately
    data.values.all? { |value| DATA_ACTION_OPTIONS.include? value }
  end

  def updates
    updates = {}
    if (state || status).present?
      updates["status"] = TaxReturnStatusHelper.status_translation(state || status)
    end
    if assigned_user.present?
      updates["assigned"] = assigned_user.name
    elsif data["assigned_user"] == REMOVE
      updates["unassigned"] = nil
    end
    updates
  end
end
