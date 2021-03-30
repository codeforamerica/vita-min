# == Schema Information
#
# Table name: client_selection_clients
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  client_id           :bigint           not null
#  client_selection_id :bigint           not null
#
# Indexes
#
#  index_client_selection_clients_on_client_id            (client_id)
#  index_client_selection_clients_on_client_selection_id  (client_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (client_selection_id => client_selections.id)
#
class ClientSelectionClient < ApplicationRecord
  belongs_to :client
  belongs_to :client_selection
end
