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

    def proof_not_required?
      if intake.filing_status_mfj?
        intake.primary_senior? && intake.spouse_senior?
      else
        intake.primary_senior?
      end
    end

    def primary_requires_proof?
      return false if proof_not_required?

      mfj_disability.in?(%w[primary both]) || primary_disabled == "yes"
    end

    def spouse_requires_proof?
      return false if proof_not_required?

      mfj_disability.in?(%w[spouse both])
    end
  end
end
