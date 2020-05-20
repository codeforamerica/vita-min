class DiyPersonalInfoForm < DiyForm
  set_attributes_for :diy_intake, :state_of_residence, :preferred_name

  validates :state_of_residence, inclusion: { in: States.keys, message: "Please select a state from the list." }
  validates :preferred_name, presence: { message: "Please enter your preferred name." }

  def save
    @diy_intake.update(attributes_for(:diy_intake))
  end
end
