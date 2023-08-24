class DemographicQuestionsForm < QuestionsForm
  set_attributes_for :intake, :demographic_questions_opt_in

  def save
    @intake.update(attributes_for(:intake))
  end
end