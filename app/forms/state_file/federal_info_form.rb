module StateFile
  class FederalInfoForm < QuestionsForm
    include DateHelper

    set_attributes_for :intake,
                       :tax_return_year,
                       :filing_status,
                       :claimed_as_dep,
                       :phone_daytime,
                       :phone_daytime_area_code,
                       :primary_dob_year,
                       :primary_dob_month,
                       :primary_dob_day,
                       :primary_first_name,
                       :primary_last_name,
                       :primary_ssn,
                       :spouse_first_name,
                       :spouse_middle_initial,
                       :spouse_last_name,
                       :spouse_dob_year,
                       :spouse_dob_month,
                       :spouse_dob_day,
                       :spouse_ssn,
                       :spouse_occupation,
                       :mailing_city,
                       :mailing_street,
                       :mailing_apartment,
                       :mailing_zip,
                       :fed_wages,
                       :fed_taxable_income,
                       :fed_unemployment,
                       :fed_taxable_ssb,
                       :total_fed_adjustments_identify,
                       :total_fed_adjustments,
                       :total_ny_tax_withheld

    def save
      exceptions = [:primary_dob_year, :primary_dob_month, :primary_dob_day, :spouse_dob_year, :spouse_dob_month, :spouse_dob_day]
      @intake.update(
        attributes_for(:intake)
          .except(*exceptions)
          .merge(
            primary_dob: parse_date_params(primary_dob_year, primary_dob_month, primary_dob_day),
            spouse_dob: parse_date_params(spouse_dob_year, spouse_dob_month, spouse_dob_day)
          )
      )
    end

    def self.existing_attributes(intake)
      attributes = HashWithIndifferentAccess.new(intake.attributes)
      if attributes[:primary_dob].present?
        birth_date = attributes[:primary_dob]
        attributes.merge!(
          primary_dob_year: birth_date.year,
          primary_dob_month: birth_date.month,
          primary_dob_day: birth_date.day,
        )
      end
      attributes
    end
  end
end