# == Schema Information
#
# Table name: signup_selections
#
#  id          :bigint           not null, primary key
#  id_array    :integer          default([]), is an Array
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
