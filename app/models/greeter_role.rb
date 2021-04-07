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
end
