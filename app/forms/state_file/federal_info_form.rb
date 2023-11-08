module StateFile
  class FederalInfoForm < QuestionsForm
    include DateHelper

    set_attributes_for :intake,
                       :claimed_as_dep

    set_attributes_for :direct_file_data,
                       :tax_return_year,
                       :filing_status,
                       :phone_daytime,
                       :phone_daytime_area_code,
                       :primary_ssn,
                       :primary_occupation,
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
                       :total_state_tax_withheld

    validate :direct_file_data_must_be_imported

    def direct_file_data_must_be_imported
      if @intake.raw_direct_file_data.blank?
        errors.add(:filing_status, "Must import from Direct File to continue!")
      end
    end

    def save
      exceptions = [
        :tax_return_year,
        :phone_daytime,
        :phone_daytime_area_code,
        :mailing_apartment,
        :total_fed_adjustments_identify,
        :total_fed_adjustments,
        :total_state_tax_withheld
      ]
      attributes_for(:direct_file_data)
        .except(*exceptions).each do |attribute, value|
        @intake.direct_file_data.send("#{attribute}=", value)
      end

      @intake.update(
        attributes_for(:intake)
          .merge(
            raw_direct_file_data: intake.direct_file_data.to_s
          )
      )
    end

    def self.existing_attributes(intake)
      attributes = HashWithIndifferentAccess.new(intake.attributes.merge(intake.direct_file_data.attributes))
      attributes
    end
  end
end