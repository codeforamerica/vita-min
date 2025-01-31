# == Schema Information
#
# Table name: az322_contributions
#
#  id                      :bigint           not null, primary key
#  amount                  :decimal(12, 2)
#  ctds_code               :string
#  date_of_contribution    :date
#  district_name           :string
#  school_name             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  state_file_az_intake_id :bigint
#
# Indexes
#
#  index_az322_contributions_on_state_file_az_intake_id  (state_file_az_intake_id)
#
class Az322Contribution < ApplicationRecord
  self.ignored_columns = [:made_contribution]

  date_accessor :date_of_contribution

  belongs_to :state_file_az_intake

  validates :school_name, presence: true
  validates :ctds_code, presence: true, format: { with: /\A\d{9}\z/, message: -> (_object, _data) { I18n.t("validators.ctds_code") }}
  validates :district_name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date_of_contribution,
            inclusion: {
              in: TAX_YEAR.beginning_of_year..TAX_YEAR.end_of_year
            },
            presence: true
end
