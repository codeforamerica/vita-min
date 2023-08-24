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
class Triage < ApplicationRecord
  belongs_to :intake, optional: true
  enum filing_status: { unfilled: 0, single: 1, jointly: 2 }, _prefix: :filing_status
  enum income_level: {
    "unfilled" => 0,
    "zero" => 1,
    "1_to_12500" => 2,
    "12500_to_25000" => 3,
    "25000_to_40000" => 4,
    "40000_to_65000" => 5,
    "65000_to_73000" => 6,
    "over_73000" => 7,
  }, _prefix: :income_level
  enum id_type: { unfilled: 0, have_id: 1, know_number: 2, need_itin_help: 3 }, _prefix: :id_type
  enum doc_type: { unfilled: 0, all_copies: 1, some_copies: 2, need_help: 3, does_not_apply: 4 }, _prefix: :doc_type
  enum filed_2018: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filed_2018
  enum filed_2019: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filed_2019
  enum filed_2020: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filed_2020
  enum filed_2021: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filed_2021
  enum assistance_in_person: { unfilled: 0, yes: 1, no: 2 }, _prefix: :assistance_in_person
  enum assistance_phone_review_english: { unfilled: 0, yes: 1, no: 2 }, _prefix: :assistance_phone_review_english
  enum assistance_phone_review_non_english: { unfilled: 0, yes: 1, no: 2 }, _prefix: :assistance_phone_review_non_english
  enum income_type_rent: { unfilled: 0, yes: 1, no: 2 }, _prefix: :income_type_rent
  enum income_type_farm: { unfilled: 0, yes: 1, no: 2 }, _prefix: :income_type_farm

  def assistance_none_yes?
    [assistance_in_person, assistance_phone_review_english, assistance_phone_review_non_english].uniq == ["no"]
  end
end
