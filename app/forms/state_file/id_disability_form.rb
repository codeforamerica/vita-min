module StateFile
  class IdDisabilityForm < QuestionsForm
    set_attributes_for :intake, :primary_disabled, :spouse_disabled

    attr_accessor :mfj_disability
    validates_presence_of :mfj_disability, if: -> { intake.show_mfj_disability_options? }
    validates :primary_disabled, inclusion: { in: %w[yes no], message: :blank }, if: -> { should_check_primary_disabled? }
    validates :spouse_disabled, inclusion: { in: %w[yes no], message: :blank }, if: -> { should_check_spouse_disabled? }

    def initialize(intake, params = {})
      super
      already_answered_disability = !intake.primary_disabled_unfilled? && !intake.spouse_disabled_unfilled?
      if intake.show_mfj_disability_options? && already_answered_disability && mfj_disability.nil?
        previously_answered_mfj_disability = disabled_attrs_to_mfj_disability(
          intake.primary_disabled, intake.spouse_disabled
        )
        self.mfj_disability = previously_answered_mfj_disability
      end
    end

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
        @intake.update(primary_disabled: mfj_disability_to_primary_disabled, spouse_disabled: mfj_disability_to_spouse_disabled)
      else
        @intake.update(attributes_for(:intake))
      end

      clean_up_followups
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

    def mfj_disability_to_disabled_attributes_hash
      {
        both: %w[yes yes],
        none: %w[no no],
        primary: %w[yes no],
        spouse: %w[no yes]
      }
    end

    def mfj_disability_to_disabled_attributes
      mfj_disability_to_disabled_attributes_hash[mfj_disability&.to_sym]
    end

    def mfj_disability_to_primary_disabled
      mfj_disability_to_disabled_attributes && mfj_disability_to_disabled_attributes[0]
    end

    def mfj_disability_to_spouse_disabled
      mfj_disability_to_disabled_attributes && mfj_disability_to_disabled_attributes[1]
    end

    def disabled_attrs_to_mfj_disability(primary_disabled, spouse_disabled)
      selected_disabled_properties = [primary_disabled, spouse_disabled]
      inverted_mfj_map = mfj_disability_to_disabled_attributes_hash.invert
      inverted_mfj_map[selected_disabled_properties]&.to_s
    end
  end
end
