# == Schema Information
#
# Table name: source_parameters
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null
#  code            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_source_parameters_on_code             (code) UNIQUE
#  index_source_parameters_on_vita_partner_id  (vita_partner_id)
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
