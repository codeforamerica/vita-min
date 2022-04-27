module Ctc
  class DriversLicenseForm < QuestionsForm
    include DateHelper

    set_attributes_for :drivers_license,
                       :license_number,
                       :state
    set_attributes_for :dates,
                       :issue_date_day,
                       :issue_date_month,
                       :issue_date_year,
                       :expiration_date_day,
                       :expiration_date_month,
                       :expiration_date_year
    validates :license_number, presence: true
    validates :state, presence: true, inclusion: { in: States.keys }
    validate :issue_date_is_valid_date
    validate :expiration_date_is_valid_date

    def save
      @intake.update(primary_drivers_license_attributes: attributes_for(:drivers_license).merge(
        issue_date: issue_date,
        expiration_date: expiration_date
        )
      )
    end

    def self.existing_attributes(intake, _attribute_keys)
      if intake.primary_drivers_license.present?
        drivers_license = intake.primary_drivers_license
        super.merge(
          issue_date_day: drivers_license.issue_date.day,
          issue_date_month: drivers_license.issue_date.month,
          issue_date_year: drivers_license.issue_date.year,
          expiration_date_day: drivers_license.expiration_date.day,
          expiration_date_month: drivers_license.expiration_date.month,
          expiration_date_year: drivers_license.expiration_date.year,
        )
      else
        super
      end
    end

    private

    def issue_date
      parse_date_params(issue_date_year, issue_date_month, issue_date_day)
    end

    def expiration_date
      parse_date_params(expiration_date_year, expiration_date_month, expiration_date_day)
    end

    def issue_date_is_valid_date
      valid_text_date(issue_date_year, issue_date_month, issue_date_day, :issue_date)
    end

    def expiration_date_is_valid_date
      valid_text_date(expiration_date_year, expiration_date_month, expiration_date_day, :expiration_date)
    end
  end
end
