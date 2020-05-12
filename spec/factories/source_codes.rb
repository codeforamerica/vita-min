# == Schema Information
#
# Table name: source_codes
#
#  id              :bigint           not null, primary key
#  code            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_source_codes_on_code             (code)
#  index_source_codes_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :source_parameter do
    code { "MyString" }
    vita_partner { nil }
  end
end
