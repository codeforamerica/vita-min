class JobCountForm < QuestionsForm
  set_attributes_for :intake, :job_count
  validates_presence_of :job_count

  def save
    # remove when earlier questions are added - this is only for the first form
    unless @intake.present?
      @intake = Intake::GyrIntake.new
    end

    @intake.update(attributes_for(:intake))
  end
end
