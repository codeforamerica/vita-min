# == Schema Information
#
# Table name: greeter_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GreeterRole < ApplicationRecord
  TYPE = "GreeterRole"

  # TODO: delete
  # has_many :greeter_organization_join_records
  # has_many :organizations, through: :greeter_organization_join_records, class_name: "VitaPartner"
  # has_many :greeter_coalition_join_records
  # has_many :coalitions, through: :greeter_coalition_join_records
end
