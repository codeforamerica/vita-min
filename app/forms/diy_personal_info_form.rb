class DiyPersonalInfoForm < DiyForm
  set_attributes_for :diy_intake, :state_of_residence, :preferred_name, :source, :referrer, :locale

  validates :state_of_residence, inclusion: { in: States.keys }
  validates :preferred_name, presence: true

  def save
    @diy_intake.update(attributes_for(:diy_intake))
  end
end
