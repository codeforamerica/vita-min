class FilingJointForm < QuestionsForm
  set_attributes_for :intake, :filing_joint

  def save
    @intake.update(attributes_for(:intake))
  end
end