# == Schema Information
#
# Table name: client_success_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ClientSuccessRole < ApplicationRecord
  TYPE = "ClientSuccessRole"
end
