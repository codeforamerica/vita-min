class PersonalInfoForm < QuestionsForm
  set_attributes_for :intake, :preferred_name, :zip_code, :timezone

  validates :zip_code, zip_code: true
  validates :preferred_name, presence: true

  def save
    state = ZipCodes.details(zip_code)[:state]
    @intake.update(attributes_for(:intake).merge(state_of_residence: state))
    @intake.assign_vita_partner!
  end
end
