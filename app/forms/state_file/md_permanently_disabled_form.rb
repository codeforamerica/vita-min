module StateFile
  class MdPermanentlyDisabledForm < QuestionsForm
    set_attributes_for :intake, :primary_disabled, :spouse_disabled, :proof_of_disability_submitted

    attr_accessor :mfj_disability
    validates_presence_of :mfj_disability, if: -> { intake.filing_status_mfj?}
    validates :primary_disabled, inclusion: { in: %w[yes no], message: :blank }, unless: -> { intake.filing_status_mfj? }
    validates :proof_of_disability_submitted, inclusion: { in: %w[yes no], message: :blank }, if: :disability_selected?


    def save
      if intake.filing_status_mfj?
        case mfj_disability
        when "me"
          @intake.update(primary_disabled: "yes", spouse_disabled: "no",  proof_of_disability_submitted: proof_of_disability_submitted)
        when "spouse"
          @intake.update(primary_disabled: "no", spouse_disabled: "yes", proof_of_disability_submitted: proof_of_disability_submitted)
        when "both"
          @intake.update(primary_disabled: "yes", spouse_disabled: "yes", proof_of_disability_submitted: proof_of_disability_submitted)
        when "none"
          @intake.update(primary_disabled: "no", spouse_disabled: "no", proof_of_disability_submitted: nil)
        end
      elsif primary_disabled == "no"
        @intake.update(
            primary_disabled: "no",
            proof_of_disability_submitted: nil
          )
      else
        @intake.update(attributes_for(:intake))
      end
    end

    private

    def disability_selected?
      mfj_disability.in?(%w[me spouse both]) || primary_disabled == "yes"
    end
  end
end
