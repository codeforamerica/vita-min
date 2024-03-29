# == Schema Information
#
# Table name: triages
#
#  id                                  :bigint           not null, primary key
#  assistance_in_person                :integer          default("unfilled"), not null
#  assistance_phone_review_english     :integer          default("unfilled"), not null
#  assistance_phone_review_non_english :integer          default("unfilled"), not null
#  doc_type                            :integer          default("unfilled"), not null
#  filed_2018                          :integer          default("unfilled"), not null
#  filed_2019                          :integer          default("unfilled"), not null
#  filed_2020                          :integer          default("unfilled"), not null
#  filed_2021                          :integer          default("unfilled"), not null
#  filing_status                       :integer          default("unfilled"), not null
#  id_type                             :integer          default("unfilled"), not null
#  income_level                        :integer          default("unfilled"), not null
#  income_type_farm                    :integer          default("unfilled"), not null
#  income_type_rent                    :integer          default("unfilled"), not null
#  locale                              :string
#  referrer                            :string
#  source                              :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  intake_id                           :bigint
#  visitor_id                          :string
#
# Indexes
#
#  index_triages_on_intake_id  (intake_id)
#
FactoryBot.define do
  factory :triage do
  end
end
