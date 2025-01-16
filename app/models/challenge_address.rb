# == Schema Information
#
# Table name: challenge_addresses
#
#  id             :bigint           not null, primary key
#  address_line_1 :string
#  city           :string
#  state          :string
#  zip            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class ChallengeAddress < ApplicationRecord
end
