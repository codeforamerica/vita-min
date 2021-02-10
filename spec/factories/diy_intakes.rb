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
FactoryBot.define do
  factory :diy_intake do
    trait :filled_out do
      locale { "es" }
      referrer { "https://www.gallopingacrosstheplains.horse/tax-help" }
      source { "horse-help" }
    end
  end
end
