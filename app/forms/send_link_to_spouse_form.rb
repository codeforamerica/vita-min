class SendLinkToSpouseForm < QuestionsForm
  set_attributes_for :spouse_verification_request, :email, :phone_number
  attr_accessor :spouse_verification_request

  validates :phone_number, allow_blank: true, phone: { message: "Please enter a valid phone number." }
  validates :email, allow_blank: true, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: "Please enter a valid email.",
  }
  validate :any_contact_info_present?

  def any_contact_info_present?
    contact_info_present = email.present? || phone_number.present?
    unless contact_info_present
      errors.add(:email, "Please enter an email or phone number.")
      errors.add(:phone_number, "Please enter an email or phone number.")
    end
    contact_info_present
  end

  def save
    attributes = attributes_for(:spouse_verification_request).merge(intake: intake)
    @spouse_verification_request = SpouseVerificationRequest.create(attributes)
  end

  def self.existing_attributes(intake)
    latest_request = intake.spouse_verification_requests.last
    if latest_request.present?
      HashWithIndifferentAccess.new(
        latest_request.attributes
      )
    else
      {}
    end
  end
end
