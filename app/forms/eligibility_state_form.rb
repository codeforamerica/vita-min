class EligibilityStateForm < QuestionsForm
  set_attributes_for :intake, :service_preference

  validates :service_preference, presence:true

  def save
    @intake.update(attributes_for(:intake))
  end
end