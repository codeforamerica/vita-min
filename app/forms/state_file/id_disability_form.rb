module StateFile
  class IdDisabilityForm < QuestionsForm
    set_attributes_for :intake, :primary_disabled, :spouse_disabled

    attr_accessor :mfj_disability
    validates_presence_of :mfj_disability, if: -> { intake.filing_status_mfj?}
    validates :primary_disabled, inclusion: { in: %w[yes no], message: :blank }, unless: -> { intake.filing_status_mfj? }

    def save
      if intake.filing_status_mfj?
        case mfj_disability
        when "me"
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
    end

    private

    def disability_selected?
      mfj_disability.in?(%w[me spouse both]) || primary_disabled == "yes"
    end
  end
end
