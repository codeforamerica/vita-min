class WagesForm < QuestionsForm
  set_attributes_for :intake, :had_wages

  def save
    # remove when earlier questions are added - this is only for the first form
    unless @intake.present?
      @intake = Intake.new
    end

    @intake.update(attributes_for(:intake))
  end
end