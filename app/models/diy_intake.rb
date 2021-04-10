# == Schema Information
#
# Table name: diy_intakes
#
#  id            :bigint           not null, primary key
#  email_address :string
#  locale        :string
#  referrer      :string
#  source        :string
#  zip_code      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  visitor_id    :string
#
class DiyIntake < ApplicationRecord
  attr_accessor :email_address_confirmation

  validates :email_address, presence: true, 'valid_email_2/email': { mx: true }, confirmation: true
end
