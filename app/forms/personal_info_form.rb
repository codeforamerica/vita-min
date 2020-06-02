class PersonalInfoForm < QuestionsForm
  set_attributes_for :intake, :state_of_residence, :preferred_name

  validates :state_of_residence, inclusion: { in: States.keys, message: I18n.t("forms.validators.state_of_residence_inclusion") }
  validates :preferred_name, presence: { message: I18n.t("forms.validators.preferred_name_presence") }

  def save
    @intake.update(attributes_for(:intake))

    @intake.assign_vita_partner!
  end
end
