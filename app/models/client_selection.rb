# == Schema Information
#
# Table name: client_selections
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ClientSelection < ApplicationRecord
  has_many :client_selection_clients
  has_many :clients, through: :client_selection_clients
end
