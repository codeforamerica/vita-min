class JobCountForm < QuestionsForm
  set_attributes_for :intake, :job_count

  def save
    @intake.update(attributes_for(:intake))
  end
end