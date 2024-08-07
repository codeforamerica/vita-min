# == Schema Information
#
# Table name: az321_contributions
#
#  id                      :bigint           not null, primary key
#  amount                  :decimal(12, 2)
#  charity_code            :string
#  charity_name            :string
#  date_of_contribution    :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  state_file_az_intake_id :bigint
#
# Indexes
#
#  index_az321_contributions_on_state_file_az_intake_id  (state_file_az_intake_id)
#
class Az321Contribution < ApplicationRecord
  attr_accessor :made_contributions

  belongs_to :state_file_az_intake

  # To satisfy date picker
  def date_of_contribution_month = date_of_contribution&.month
  def date_of_contribution_day = date_of_contribution&.day
  def date_of_contribution_year = date_of_contribution&.year

  def date_of_contribution_month=(month)
    change_date_of_contribution(month: month) unless month.empty?
  end

  def date_of_contribution_day=(day)
    change_date_of_contribution(day: day) unless day.empty?
  end

  def date_of_contribution_year=(year)
    change_date_of_contribution(year: year) unless year.empty?
  end

  private

  # Takes in valid arguments to Date#change. Will create a new date if
  # `date_of_contribution` is nil, otherwise will merely modify the correct
  # date part. Values can be strings as long as #to_i renders an appropriate
  # integer
  #
  # @see {Date#change}
  #
  # @param args [Hash<Symbol, String | Integer>] Arguments conforming to Date#change
  # @return [String | Integer] Whatever the date_part passed in was. Incidental
  def change_date_of_contribution(args)
    existing_date = date_of_contribution || Date.new

    self.date_of_contribution = existing_date.change(
      **args.transform_values(&:to_i)
    )
  end
end
