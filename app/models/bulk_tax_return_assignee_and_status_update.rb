# == Schema Information
#
# Table name: bulk_tax_return_assignee_and_status_updates
#
#  id                      :bigint           not null, primary key
#  status                  :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  assigned_user_id        :bigint
#  tax_return_selection_id :bigint           not null
#
# Indexes
#
#  index_btraasu_on_assigned_user_id         (assigned_user_id)
#  index_btraasu_on_tax_return_selection_id  (tax_return_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#
class BulkTaxReturnAssigneeAndStatusUpdate < ApplicationRecord
  has_one :user_notification, as: :notifiable
  belongs_to :tax_return_selection
  belongs_to :assigned_user, class_name: "User", optional: true

  enum status: TaxReturnStatus::STATUSES, _prefix: :status
end
