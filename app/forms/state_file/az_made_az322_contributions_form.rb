module StateFile
  class AzMadeAz322ContributionsForm < QuestionsForm
    set_attributes_for :intake, :made_az322_contributions

    validates :made_az322_contributions, inclusion: { in: %w[yes no], message: :blank }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end