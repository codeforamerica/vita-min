module StateFile
  class AllInfoForm < QuestionsForm
    include DateHelper

    set_attributes_for :intake,
                       :tax_return_year,
                       :primary_dob_year,
                       :primary_dob_month,
                       :primary_dob_day,
                       :primary_first_name,
                       :primary_last_name,
                       :primary_ssn,
                       :mailing_city,
                       :mailing_street,
                       :mailing_zip

    def save
      exceptions = [:primary_dob_year, :primary_dob_month, :primary_dob_day]
      @intake.update(
        attributes_for(:intake)
          .except(*exceptions)
          .merge(
            primary_dob: parse_date_params(primary_dob_year, primary_dob_month, primary_dob_day)
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