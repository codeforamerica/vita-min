# == Schema Information
#
# Table name: bulk_client_notes
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  client_selection_id :bigint           not null
#
# Indexes
#
#  index_bulk_client_notes_on_client_selection_id  (client_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_selection_id => client_selections.id)
#
FactoryBot.define do
  factory :bulk_client_note do
    client_selection
  end
end
