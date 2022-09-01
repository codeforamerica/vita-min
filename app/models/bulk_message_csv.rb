# == Schema Information
#
# Table name: bulk_message_csvs
#
#  id                      :bigint           not null, primary key
#  status                  :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  tax_return_selection_id :bigint
#  user_id                 :bigint
#
# Indexes
#
#  index_bulk_message_csvs_on_tax_return_selection_id  (tax_return_selection_id)
#  index_bulk_message_csvs_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#  fk_rails_...  (user_id => users.id)
#
class BulkMessageCsv < ApplicationRecord
  has_one_attached :upload
  belongs_to :tax_return_selection, optional: true
  belongs_to :user
  enum status: { queued: 0, completed: 100}
end
