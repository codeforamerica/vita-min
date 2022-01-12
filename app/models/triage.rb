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

end
