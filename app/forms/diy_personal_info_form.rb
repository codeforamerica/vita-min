class DiyPersonalInfoForm < DiyForm
  set_attributes_for :diy_intake, :state_of_residence, :preferred_name, :source, :referrer, :locale

  validates :state_of_residence, inclusion: { in: States.keys, message: I18n.t("forms.validators.state_of_residence_inclusion") }
  validates :preferred_name, presence: { message: I18n.t("forms.validators.preferred_name_presence") }

  def save
    @diy_intake.update(attributes_for(:diy_intake))
  end
end
