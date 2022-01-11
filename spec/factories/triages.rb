# == Schema Information
#
# Table name: triages
#
#  id                                  :bigint           not null, primary key
#  assistance_chat                     :boolean
#  assistance_in_person                :boolean
#  assistance_none                     :boolean
#  assistance_phone_review_english     :boolean
#  assistance_phone_review_non_english :boolean
#  backtaxes_2018                      :boolean
#  backtaxes_2019                      :boolean
#  backtaxes_2020                      :boolean
#  backtaxes_2021                      :boolean
#  doc_type                            :integer
#  id_type                             :integer
#  income_level                        :integer
#  locale                              :string
#  referrer                            :string
#  source                              :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  visitor_id                          :string
#
FactoryBot.define do
  factory :triage do
  end
end
