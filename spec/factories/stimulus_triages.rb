# == Schema Information
#
# Table name: stimulus_triages
#
#  id                :bigint           not null, primary key
#  chose_to_file     :integer          default("unfilled"), not null
#  filed_prior_years :integer          default("unfilled"), not null
#  filed_recently    :integer          default("unfilled"), not null
#  need_to_correct   :integer          default("unfilled"), not null
#  need_to_file      :integer          default("unfilled"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
FactoryBot.define do
  factory :stimulus_triage do
    filed_recently { 1 }
    need_to_correct { 1 }
    filed_prior_years { 1 }
    need_to_file { 1 }
    chose_to_file { 1 }
  end
end
