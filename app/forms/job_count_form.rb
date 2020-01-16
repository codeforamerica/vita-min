class JobCountForm < QuestionsForm
  set_attributes_for :intake, :job_count

  def save
    # remove when earlier questions are added - this is only for the first form
    unless @intake.present?
      @intake = Intake.new
    end

    @intake.update(attributes_for(:intake))
  end
end