# == Schema Information
#
# Table name: bulk_client_messages
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  tax_return_selection_id :bigint
#
# Indexes
#
#  index_bcm_on_tax_return_selection_id  (tax_return_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#
FactoryBot.define do
  factory :bulk_client_message do
    tax_return_selection
  end
end
