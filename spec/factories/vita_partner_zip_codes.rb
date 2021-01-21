# == Schema Information
#
# Table name: vita_partner_zip_codes
#
#  id              :bigint           not null, primary key
#  zip_code        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_vita_partner_zip_codes_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :vita_partner_zip_code do
    zip_code { "73130" }
    vita_partner { build(:vita_partner) }
  end
end
