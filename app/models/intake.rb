# == Schema Information
#
# Table name: intakes
#
#  id                     :bigint           not null, primary key
#  has_scholarship_income :integer          default("unfilled"), not null
#  has_wages              :integer          default("unfilled"), not null
#

class Intake < ApplicationRecord
  enum has_wages: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_wages
  enum has_scholarship_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_scholarship_income

  def pdf
    IntakePdf.new(self).output_file
  end
end
