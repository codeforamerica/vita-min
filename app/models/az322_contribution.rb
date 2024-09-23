# == Schema Information
#
# Table name: az322_contributions
#
#  id                      :bigint           not null, primary key
#  amount                  :decimal(12, 2)
#  ctds_code               :string
#  date_of_contribution    :date
#  district_name           :string
#  made_contribution       :integer          default("unfilled"), not null
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
  date_accessor :date_of_contribution

  belongs_to :state_file_az_intake

  enum made_contribution: { unfilled: 0, yes: 1, no: 2 }, _prefix: :made_contribution

  validates_inclusion_of :made_contribution, in: ['yes', 'no'], message: ->(_object, _data) { I18n.t("errors.messages.blank") }
  validates :school_name, presence: true, if: -> { made_contribution == "yes" }
  validates :ctds_code, presence: true, format: { with: /\A\d{9}\z/, message: -> (_object, _data) { I18n.t("validators.ctds_code") }}, if: -> { made_contribution == "yes" }
  validates :district_name, presence: true, if: -> { made_contribution == "yes" }
  validates :amount, presence: true, numericality: { greater_than: 0 }, if: -> { made_contribution == "yes" }
  validate :amount_format

  validates :date_of_contribution,
            inclusion: {
              in: TAX_YEAR.beginning_of_year..TAX_YEAR.end_of_year
            },
            presence: true

  # Custom validation for handling values before they are coerced into decimal(12, 2) type
  def amount=(value)
    write_attribute :amount, value&.to_s&.chomp('.') # Remove trailing decimal. Ex: '10.'
  end

  private

  VALID_MONEY_REGEXP = /\A(\d+)?\.?\d{0,2}\z/.freeze
  def amount_format
    return true if amount.blank?

    unless VALID_MONEY_REGEXP.match?(read_attribute_before_type_cast(:amount).to_s)
      errors.add(:amount, 'must be a valid dollar amount')
    end
  end
end
