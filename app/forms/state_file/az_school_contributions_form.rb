module StateFile
  class AzSchoolContributionsForm < QuestionsForm
    set_attributes_for :intake, :school_contributions

    validates :school_contributions, inclusion: { in: %w[yes no], message: :blank }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end