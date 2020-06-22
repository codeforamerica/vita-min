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
require 'rails_helper'

RSpec.describe StimulusTriage, type: :model do
  it do
    is_expected.to define_enum_for(:need_to_correct)
      .with_values({ unfilled: 0, yes: 1, no: 2 })
      .with_prefix(:need_to_correct)
  end
  it do
    is_expected.to define_enum_for(:filed_prior_years)
      .with_values({ unfilled: 0, yes: 1, no: 2 })
      .with_prefix(:filed_prior_years)
  end
  it do
    is_expected.to define_enum_for(:need_to_file)
      .with_values({ unfilled: 0, yes: 1, no: 2 })
      .with_prefix(:need_to_file)
  end
  it do
    is_expected.to define_enum_for(:filed_recently)
      .with_values({ unfilled: 0, yes: 1, no: 2 })
      .with_prefix(:filed_recently)
  end
  it do
    is_expected.to define_enum_for(:chose_to_file)
      .with_values({ unfilled: 0, yes: 1, no: 2 })
      .with_prefix(:chose_to_file)
  end
end
