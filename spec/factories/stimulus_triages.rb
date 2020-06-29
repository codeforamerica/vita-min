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
#  referrer          :string
#  source            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  visitor_id        :string
#
FactoryBot.define do
  factory :stimulus_triage do
  end
end
