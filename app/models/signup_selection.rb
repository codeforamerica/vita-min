# == Schema Information
#
# Table name: signup_selections
#
#  id          :bigint           not null, primary key
#  filename    :text             not null
#  id_array    :integer          not null, is an Array
#  signup_type :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_signup_selections_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class SignupSelection < ApplicationRecord
  belongs_to :user
  validates_presence_of :id_array, :signup_type, :filename
  has_many :bulk_signup_messages
  enum signup_type: { GYR: 1, GetCTC: 2 }
end
