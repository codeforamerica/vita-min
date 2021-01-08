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
  DISPLAY_NAME = I18n.t("general.client_success")

  belongs_to :coalition
end
