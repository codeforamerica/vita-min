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

      clean_up_followups
    end

    private

    def clean_up_followups
      primary_followups =  @intake.filer_1099_rs(:primary).map(&:state_specific_followup).compact
      if primary_disabled == "no" || ["spouse", "none"].include?(mfj_disability)
        primary_followups.each(&:destroy)
      end

      if @intake.filing_status_mfj? && ["me", "none"].include?(mfj_disability)
        spouse_followups =  @intake.filer_1099_rs(:spouse).map(&:state_specific_followup).compact
        spouse_followups.each(&:destroy)
      end
    end

    def eligible?(primary_or_spouse)
      person = intake.send(primary_or_spouse)
      birth_date = person.birth_date
      return false unless birth_date.present?

      age = intake.calculate_age(birth_date, inclusive_of_jan_1: true)
      age_eligible = age >= 62 && age < 65

      has_taxable_1099r = intake.state_file1099_rs.any? do |form|
        form.recipient_ssn == person.ssn && form.taxable_amount&.to_f&.positive?
      end

      age_eligible && has_taxable_1099r
    end
  end
end
