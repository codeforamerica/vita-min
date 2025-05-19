module StateFile
  class IdDisabilityForm < QuestionsForm
    set_attributes_for :intake, :primary_disabled, :spouse_disabled, :mfj_disability

    attr_accessor :mfj_disability
    validates_presence_of :mfj_disability, if: -> { intake.show_mfj_disability_options? }
    validates :primary_disabled, inclusion: { in: %w[yes no], message: :blank }, if: -> { should_check_primary_disabled? }
    validates :spouse_disabled, inclusion: { in: %w[yes no], message: :blank }, if: -> { should_check_spouse_disabled? }

    def should_check_primary_disabled?
      return false if intake.show_mfj_disability_options?

      intake.primary_between_62_and_65_years_old?
    end

    def should_check_spouse_disabled?
      return false if intake.show_mfj_disability_options?

      intake.filing_status_mfj? && intake.spouse_between_62_and_65_years_old?
    end

    def save
      if intake.show_mfj_disability_options?
        mfj_disability_to_disabled_attributes = self.class.mfj_disability_to_disabled_attributes_hash[mfj_disability&.to_sym] || {}

        @intake.update(
          primary_disabled: mfj_disability_to_disabled_attributes && mfj_disability_to_disabled_attributes[:primary],
          spouse_disabled: mfj_disability_to_disabled_attributes && mfj_disability_to_disabled_attributes[:spouse]
        )
      else
        @intake.update(attributes_for(:intake).except(:mfj_disability))
      end

      clean_up_followups
    end

    def self.existing_attributes(intake)
      already_answered_disability = !intake.primary_disabled_unfilled? && !intake.spouse_disabled_unfilled?
      if already_answered_disability
        mfj_disability = case [intake.primary_disabled, intake.spouse_disabled]
                         when ["yes", "yes"]
                           "both"
                         when ["no", "no"]
                           "none"
                         when ["yes", "no"]
                           "primary"
                         when ["no", "yes"]
                           "spouse"
                         else
                           nil
                         end
        super.merge(mfj_disability: mfj_disability)
      else
        super
      end
    end

    def self.mfj_disability_to_disabled_attributes_hash
      {
        both: { primary: "yes", spouse: "yes" },
        none: { primary: "no", spouse: "no" },
        primary: { primary: "yes", spouse: "no" },
        spouse: { primary: "no", spouse: "yes" },
      }
    end

    private

    def clean_up_followups
      if primary_disabled == "no" || %w[spouse none].include?(mfj_disability)
        primary_followups = @intake.filer_1099_rs(:primary).map(&:state_specific_followup).compact
        primary_followups.each(&:destroy)
      end

      if @intake.filing_status_mfj? && (spouse_disabled == "no" || %w[primary none].include?(mfj_disability))
        spouse_followups = @intake.filer_1099_rs(:spouse).map(&:state_specific_followup).compact
        spouse_followups.each(&:destroy)
      end
    end
  end
end
