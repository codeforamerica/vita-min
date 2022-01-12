# == Schema Information
#
# Table name: triages
#
#  id                                  :bigint           not null, primary key
#  assistance_chat                     :integer          default("unfilled"), not null
#  assistance_in_person                :integer          default("unfilled"), not null
#  assistance_phone_review_english     :integer          default("unfilled"), not null
#  assistance_phone_review_non_english :integer          default("unfilled"), not null
#  backtaxes_2018                      :integer          default("unfilled"), not null
#  backtaxes_2019                      :integer          default("unfilled"), not null
#  backtaxes_2020                      :integer          default("unfilled"), not null
#  backtaxes_2021                      :integer          default("unfilled"), not null
#  doc_type                            :integer
#  id_type                             :integer
#  income_level                        :integer
#  income_type_farm                    :integer          default("unfilled"), not null
#  income_type_rent                    :integer          default("unfilled"), not null
#  locale                              :string
#  referrer                            :string
#  source                              :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  visitor_id                          :string
#
class Triage < ApplicationRecord
  enum income_level: {
    unfilled: 0,
    zero: 1,
    hh_1_to_25100: 2,
    hh_25101_to_66000: 3,
    hh_66000_to_73000: 4,
    hh_over_73000: 5
  }, _prefix: :income_level
  enum id_type: { unfilled: 0, have_paperwork: 1, know_number: 2, need_help: 3 }, _prefix: :id_type
  enum doc_type: { unfilled: 0, all_copies: 1, some_copies: 2, need_help: 3, does_not_apply: 4 }, _prefix: :doc_type
  enum backtaxes_2018: { unfilled: 0, yes: 1, no: 2 }, _prefix: :backtaxes_2018
  enum backtaxes_2019: { unfilled: 0, yes: 1, no: 2 }, _prefix: :backtaxes_2019
  enum backtaxes_2020: { unfilled: 0, yes: 1, no: 2 }, _prefix: :backtaxes_2020
  enum backtaxes_2021: { unfilled: 0, yes: 1, no: 2 }, _prefix: :backtaxes_2021
  enum assistance_in_person: { unfilled: 0, yes: 1, no: 2 }, _prefix: :assistance_in_person
  enum assistance_chat: { unfilled: 0, yes: 1, no: 2 }, _prefix: :assistance_chat
  enum assistance_phone_review_english: { unfilled: 0, yes: 1, no: 2 }, _prefix: :assistance_phone_review_english
  enum assistance_phone_review_non_english: { unfilled: 0, yes: 1, no: 2 }, _prefix: :assistance_phone_review_non_english
  enum assistance_none: { unfilled: 0, yes: 1, no: 2 }, _prefix: :assistance_none
  enum income_type_rent: { unfilled: 0, yes: 1, no: 2 }, _prefix: :income_type_rent
  enum income_type_farm: { unfilled: 0, yes: 1, no: 2 }, _prefix: :income_type_farm
end
