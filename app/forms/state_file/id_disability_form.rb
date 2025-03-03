module StateFile
  class IdDisabilityForm < QuestionsForm
    set_attributes_for :intake, :primary_disabled, :spouse_disabled

    attr_accessor :mfj_disability
    validates_presence_of :mfj_disability, if: -> { intake.filing_status_mfj?}
    validates :primary_disabled, inclusion: { in: %w[yes no], message: :blank }, unless: -> { intake.filing_status_mfj? }

    def save
      if intake.filing_status_mfj?
        case mfj_disability
        when "primary"
          @intake.update(primary_disabled: "yes", spouse_disabled: "no")
        when "spouse"
          @intake.update(primary_disabled: "no", spouse_disabled: "yes")
        when "both"
          @intake.update(primary_disabled: "yes", spouse_disabled: "yes")
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
      if primary_disabled == "no" || %w[spouse none].include?(mfj_disability)
        primary_followups.each(&:destroy)
      end

      if @intake.filing_status_mfj? && %w[primary none].include?(mfj_disability)
        spouse_followups =  @intake.filer_1099_rs(:spouse).map(&:state_specific_followup).compact
        spouse_followups.each(&:destroy)
      end
    end
  end
end
