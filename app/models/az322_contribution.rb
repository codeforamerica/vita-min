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
  include DateHelper
  belongs_to :state_file_az_intake

  enum made_contribution: { unfilled: 0, yes: 1, no: 2 }, _prefix: :made_contribution

  validates_inclusion_of :made_contribution, in: ['yes', 'no'], message: ->(_object, _data) { I18n.t("errors.messages.blank") }
  validates :school_name, presence: true, if: -> { made_contribution == "yes" }
  validates :ctds_code, presence: true, format: { with: /\A\d{9}\z/, message: -> (_object, _data) { I18n.t("validators.ctds_code") }}, if: -> { made_contribution == "yes" }
  validates :district_name, presence: true, if: -> { made_contribution == "yes" }
  validates :amount, presence: true, numericality: { greater_than: 0 }, if: -> { made_contribution == "yes" }
  validate :date_of_contribution_is_valid_date, if: -> { made_contribution == "yes" }

  attr_accessor :date_of_contribution_day, :date_of_contribution_month, :date_of_contribution_year

  before_validation :set_date_of_contribution, if: -> { made_contribution == "yes" }

  private

  def set_date_of_contribution
    if date_of_contribution_year.present? || date_of_contribution_month.present? || date_of_contribution_day.present?
      self.date_of_contribution = parse_date_params(date_of_contribution_year, date_of_contribution_month, date_of_contribution_day)
    end
  end

  def parse_date_params(year, month, day)
    Date.new(year.to_i, month.to_i, day.to_i) rescue nil
  end

  def date_of_contribution_is_valid_date
    if date_of_contribution_year.present? || date_of_contribution_month.present? || date_of_contribution_day.present?
      valid_text_date(date_of_contribution_year, date_of_contribution_month, date_of_contribution_day, :date_of_contribution)
    else
      if ((DateTime.parse(date_of_contribution) rescue ArgumentError) == ArgumentError)
        errors.add(:date_of_contribution, I18n.t('errors.attributes.birth_date.blank'))
        return false
      end

      true
    end
  end
end
