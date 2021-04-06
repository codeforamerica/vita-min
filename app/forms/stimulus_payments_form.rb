class StimulusPaymentsForm < QuestionsForm
  set_attributes_for :intake, :received_stimulus_payment

  def save
    @intake.update(attributes_for(:intake))
  end
end