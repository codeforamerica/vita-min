module StateFile
  class AzPriorLastNamesForm < QuestionsForm
    set_attributes_for :intake, :prior_last_names, :has_prior_last_names
    validates :has_prior_last_names, inclusion: { in: %w[yes no], message: :blank }
    validates :prior_last_names, presence: true, allow_blank: false, if: -> { has_prior_last_names == "yes" }

    def save
      if has_prior_last_names == "no"
        @intake.update(has_prior_last_names: "no", prior_last_names: nil)
      else
        @intake.update(attributes_for(:intake))
      end
    end
  end
end