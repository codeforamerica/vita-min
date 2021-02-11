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
  # Production has some DIY Intakes that were created up until Feb 8th, 2021.
  # The app doesn't use this anymore, but we'll keep it in case we want to easily access it in the future.
end
