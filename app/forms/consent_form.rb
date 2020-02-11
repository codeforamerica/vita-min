class ConsentForm < QuestionsForm
  set_attributes_for :user, :consented_to_service, :consented_to_service_ip, :consented_to_service_at
  validates :consented_to_service, acceptance: { accept: "yes", message: "We need your consent to continue." }

  def save
    intake.primary_user.update(attributes_for(:user))
  end

  def self.existing_attributes(intake)
    HashWithIndifferentAccess.new(intake.primary_user.attributes)
  end
end
