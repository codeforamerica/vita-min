module StateFile
  class MdPermanentlyDisabledForm < QuestionsForm
    set_attributes_for :intake, :mfj_disability, :primary_disabled, :spouse_disabled, :primary_proof_of_disability_submitted, :spouse_proof_of_disability_submitted

    validates_presence_of :mfj_disability, if: -> { intake.filing_status_mfj? }
    validates :primary_disabled, inclusion: { in: %w[yes no], message: :blank }, unless: -> { intake.filing_status_mfj? }
    validates :primary_proof_of_disability_submitted, inclusion: { in: %w[yes no], message: :blank }, if: :primary_requires_proof?
    validates :spouse_proof_of_disability_submitted, inclusion: { in: %w[yes no], message: :blank }, if: :spouse_requires_proof?

    def save
      attributes_to_save = attributes_for(:intake).except(:mfj_disability)
      if mfj_disability.present?
        attributes_to_save = case mfj_disability
                             when "primary"
                               attributes_to_save.merge(primary_disabled: "yes", spouse_disabled: "no")
                             when "spouse"
                               attributes_to_save.merge(primary_disabled: "no", spouse_disabled: "yes")
                             when "both"
                               attributes_to_save.merge(primary_disabled: "yes", spouse_disabled: "yes")
                             when "none"
                               attributes_to_save.merge(primary_disabled: "no", spouse_disabled: "no")
                             end
      end

      @intake.update(attributes_to_save)
    end

    private

    def self.existing_attributes(intake)
      already_answered_disability = !intake.primary_disabled_unfilled? && !intake.spouse_disabled_unfilled?

      if already_answered_disability
        case [intake.primary_disabled, intake.spouse_disabled]
          when ["yes", "yes"]
            mfj_disability = "both"
          when ["no", "no"]
            mfj_disability = "none"
          when ["yes", "no"]
            mfj_disability = "primary"
          when ["no", "yes"]
            mfj_disability = "spouse"
          else
            mfj_disability = nil
        end
        super.merge(mfj_disability: mfj_disability)
      else
        super
      end
    end

    def primary_requires_proof?
      return false unless intake.should_warn_about_pension_exclusion?

      mfj_disability.in?(%w[primary both]) || primary_disabled == "yes"
    end

    def spouse_requires_proof?
      return false unless intake.should_warn_about_pension_exclusion?

      mfj_disability.in?(%w[spouse both])
    end
  end
end
