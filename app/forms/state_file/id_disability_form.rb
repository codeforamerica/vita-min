module StateFile
  class IdDisabilityForm < QuestionsForm
    set_attributes_for :intake, :primary_disabled, :spouse_disabled

    attr_accessor :mfj_disability
    validates_presence_of :mfj_disability, if: -> { intake.filing_status_mfj?}
    validates :primary_disabled, inclusion: { in: %w[yes no], message: :blank }, unless: -> { intake.filing_status_mfj? }

    def save
      if intake.filing_status_mfj?
        primary_eligible = eligible?(:primary)
        spouse_eligible = eligible?(:spouse)

        case mfj_disability
        when "me"
          @intake.update(primary_disabled: primary_eligible ? "yes" : "no", spouse_disabled: "no")
        when "spouse"
          @intake.update(primary_disabled: "no", spouse_disabled: spouse_eligible ? "yes" : "no")
        when "both"
          @intake.update(
            primary_disabled: primary_eligible ? "yes" : "no",
            spouse_disabled: spouse_eligible ? "yes" : "no"
          )
        when "none"
          @intake.update(primary_disabled: "no", spouse_disabled: "no")
        end
      else
        @intake.update(
          primary_disabled: eligible?(:primary) ? primary_disabled : "no",
          spouse_disabled: "no"
        )
      end
    end

    private

    def eligible?(person)
      age = intake.calculate_age(
        person == :primary ? intake.primary_birth_date : intake.spouse_birth_date,
        inclusive_of_jan_1: true
      )

      ssn = if person == :primary
              intake.direct_file_json_data.primary_filer
            else
              intake.direct_file_json_data.spouse_filer
            end

      age_eligible = age >= 62 && age < 65
      has_taxable_1099r = current_intake.forms_1099r.any? do |form|
        form.recipient_ssn == ssn && form.taxable_amount&.to_f&.positive?
      end

      age_eligible && has_taxable_1099r
    end

    def disability_selected?
      mfj_disability.in?(%w[me spouse both]) || primary_disabled == "yes"
    end
  end
end
