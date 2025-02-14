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
        @intake.update(attributes_for(:intake))
      end
    end

    private

    def eligible?(person)
      birth_date = if person == :primary
                     intake.primary_birth_date
                   else
                     intake.spouse_birth_date
                   end
      return false unless birth_date.present?

      age = intake.calculate_age(birth_date, inclusive_of_jan_1: true)

      ssn = if person == :primary
              intake.primary.ssn
            else
              intake.spouse.ssn
            end

      age_eligible = age >= 62 && age < 65
      has_taxable_1099r = intake.state_file1099_rs.any? do |form|
        form.recipient_ssn == ssn && form.taxable_amount&.to_f&.positive?
      end

      age_eligible && has_taxable_1099r
    end
  end
end
