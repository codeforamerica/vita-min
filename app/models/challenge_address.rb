# == Schema Information
#
# Table name: challenge_addresses
#
#  id         :bigint           not null, primary key
#  address    :string           not null
#  state_code :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ChallengeAddress < ApplicationRecord
end
