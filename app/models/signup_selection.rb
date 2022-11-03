# == Schema Information
#
# Table name: signup_selections
#
#  id          :bigint           not null, primary key
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
  has_one_attached :upload
  belongs_to :user
  validates_presence_of :upload, :signup_type
  enum signup_type: { GYR: 1, GetCTC: 2 }
end
