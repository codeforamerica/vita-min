# == Schema Information
#
# Table name: admin_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AdminRole < ApplicationRecord
  TYPE = "AdminRole"
  DISPLAY_NAME = "Administrator"
end
