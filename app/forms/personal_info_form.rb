class PersonalInfoForm < QuestionsForm
  set_attributes_for :intake, :state_of_residence, :preferred_name

  validates :state_of_residence, inclusion: { in: States.keys, message: "Please select a state from the list." }
  validates :preferred_name, presence: { message: "Please enter your preferred name." }

  def save
    @intake.update(attributes_for(:intake))

    @intake.assign_vita_partner!
  end
end
