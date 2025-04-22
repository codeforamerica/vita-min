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
                             else
                               attributes_to_save
                             end
      end

      @intake.update(attributes_to_save)
    end

    def self.existing_attributes(intake)

      # base_attrs = super
      #
      # # Only include proof fields if explicitly answered (not :unfilled)
      # if intake.primary_proof_of_disability_submitted_yes? || intake.primary_proof_of_disability_submitted_no?
      #   base_attrs[:primary_proof_of_disability_submitted] = intake.primary_proof_of_disability_submitted
      # end

      # if intake.filing_status_mfj?
      #   if intake.spouse_proof_of_disability_submitted_yes? || intake.spouse_proof_of_disability_submitted_no?
      #     base_attrs[:spouse_proof_of_disability_submitted] = intake.spouse_proof_of_disability_submitted
      #   end
      #
      #   already_answered_disability = !intake.primary_disabled_unfilled? && !intake.spouse_disabled_unfilled?
      #   if already_answered_disability
      #     value = { primary: intake.primary_disabled, spouse: intake.spouse_disabled }
      #     previously_answered_mfj_disability = mfj_disability_to_disabled_attributes_hash.key(value)&.to_s
      #     base_attrs[:mfj_disability] = previously_answered_mfj_disability
      #   end
      # end
      binding.pry
              super.merge(
                primary_proof_of_disability_submitted: intake.primary_proof_of_disability_submitted,
              )
    end

    def self.mfj_disability_to_disabled_attributes_hash
      {
        both: { primary: "yes", spouse: "yes" },
        none: { primary: "no", spouse: "no" },
        primary: { primary: "yes", spouse: "no" },
        spouse: { primary: "no", spouse: "yes" }
      }
    end

    private

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
