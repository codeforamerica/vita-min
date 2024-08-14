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
  date_accessor :date_of_contribution

  belongs_to :state_file_az_intake

  # Virtual attribute, not in database. Only checked when created via form interface.
  validates :made_contributions, presence: true, on: :form_create

  validates :charity_name, presence: true
  validates :charity_code, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date_of_contribution,
    inclusion: {
      in: TAX_YEAR.beginning_of_year..TAX_YEAR.end_of_year
    },
    presence: true
end
