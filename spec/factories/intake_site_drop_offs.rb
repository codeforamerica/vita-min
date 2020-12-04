# == Schema Information
#
# Table name: intake_site_drop_offs
#
#  id                  :bigint           not null, primary key
#  additional_info     :string
#  certification_level :string
#  email               :string
#  hsa                 :boolean          default(FALSE)
#  intake_site         :string           not null
#  name                :string           not null
#  organization        :string
#  phone_number        :string
#  pickup_date         :date
#  signature_method    :string           not null
#  state               :string
#  timezone            :string
#  created_at          :datetime
#  updated_at          :datetime
#  prior_drop_off_id   :bigint
#  zendesk_ticket_id   :string
#
# Indexes
#
#  index_intake_site_drop_offs_on_prior_drop_off_id  (prior_drop_off_id)
#
# Foreign Keys
#
#  fk_rails_...  (prior_drop_off_id => intake_site_drop_offs.id)
#

FactoryBot.define do
  factory :intake_site_drop_off do
    name { "Gary Guava" }
    intake_site { "Adams City High School" }
    organization { "thc" }
    state { "CO" }
    signature_method { :e_signature }

    trait :optional_fields do
      email { "gguava@example.com" }
      phone_number { "+14158161286" }
      pickup_date { Date.new(2020, 4, 10) }
      additional_info { "Gary is missing a document" }
      timezone { "America/Denver" }
      certification_level { "Basic" }
      hsa { true }
    end

    factory :full_drop_off do
      optional_fields
    end
  end
end
