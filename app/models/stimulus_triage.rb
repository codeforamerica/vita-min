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
class StimulusTriage < ApplicationRecord
  enum filed_recently: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filed_recently
  enum need_to_correct: { unfilled: 0, yes: 1, no: 2 }, _prefix: :need_to_correct
  enum filed_prior_years: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filed_prior_years
  enum need_to_file: { unfilled: 0, yes: 1, no: 2 }, _prefix: :need_to_file
  enum chose_to_file: { unfilled: 0, yes: 1, no: 2 }, _prefix: :chose_to_file
end
