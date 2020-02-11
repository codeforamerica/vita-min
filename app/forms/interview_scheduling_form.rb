class InterviewSchedulingForm < QuestionsForm
  set_attributes_for :intake, :interview_timing_preference

  def save
    @intake.update(attributes_for(:intake))
  end
end