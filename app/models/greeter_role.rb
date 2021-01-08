class GreeterRole < ApplicationRecord
  TYPE = "GreeterRole"

  belongs_to :organization, foreign_key: "vita_partner_id", class_name: "VitaPartner"
  belongs_to :coalition
end
