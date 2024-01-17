# == Schema Information
#
# Table name: state_ids
#
#  id                  :bigint           not null, primary key
#  expiration_date     :date
#  first_three_doc_num :string
#  id_number           :string
#  id_type             :integer          default("unfilled"), not null
#  issue_date          :date
#  non_expiring        :boolean          default(FALSE)
#  state               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
FactoryBot.define do
  factory :state_id do
    id_type {"driver_license"}
    id_number { "123456789" }
    state { "NY" }
    issue_date { Date.new(2020, 11, 11) }
    expiration_date { Date.new(2028, 11, 11) }
    first_three_doc_num { "123" }
    non_expiring { false }

    trait :non_expiring do
      expiration_date { nil }
      non_expiring { true }
    end

    trait :non_ny do
      state { "UT" }
      first_three_doc_num { nil }
    end

    trait :state_issued_id do
      id_type { "dmv_bmv" }
    end
  end
end
