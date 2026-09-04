# == Schema Information
#
# Table name: bulk_client_flag_updates
#
#  id                      :bigint           not null, primary key
#  enabled                 :boolean          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  tax_return_selection_id :bigint           not null
#
# Indexes
#
#  index_bulk_client_flag_updates_on_tax_return_selection_id  (tax_return_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#
FactoryBot.define do
  factory :bulk_client_flag_update do
    tax_return_selection
    enabled { true }
  end
end
