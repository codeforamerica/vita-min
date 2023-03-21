# == Schema Information
#
# Table name: diy_intakes
#
#  id                   :bigint           not null, primary key
#  email_address        :string
#  filing_frequency     :integer          default("unfilled"), not null
#  locale               :string
#  preferred_first_name :string
#  received_1099        :integer          default("unfilled"), not null
#  referrer             :string
#  source               :string
#  zip_code             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  visitor_id           :string
#
FactoryBot.define do
  factory :diy_intake do
    trait :filled_out do
      locale { "es" }
      referrer { "https://www.gallopingacrosstheplains.horse/tax-help" }
      sequence(:email_address) { |n| "diy_intake_#{n}@example.com" }
      source { "horse-help" }
    end
  end
end
