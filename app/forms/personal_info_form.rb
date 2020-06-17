class PersonalInfoForm < QuestionsForm
  set_attributes_for :intake, :state_of_residence, :preferred_name

  validates :state_of_residence, inclusion: { in: States.keys }
  validates :preferred_name, presence: true

  def save
    @intake.update(attributes_for(:intake))

    @intake.assign_vita_partner!
  end
end
