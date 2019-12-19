# == Schema Information
#
# Table name: intakes
#
#  id                     :bigint           not null, primary key
#  has_scholarship_income :integer          default("unfilled"), not null
#  has_wages              :integer          default("unfilled"), not null
#

FactoryBot.define do
  factory :intake do
    has_wages { :unfilled }
    has_scholarship_income { :unfilled }
  end
end
