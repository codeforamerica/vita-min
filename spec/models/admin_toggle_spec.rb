# == Schema Information
#
# Table name: admin_toggles
#
#  id         :bigint           not null, primary key
#  name       :string
#  value      :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_admin_toggles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe AdminToggle, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
