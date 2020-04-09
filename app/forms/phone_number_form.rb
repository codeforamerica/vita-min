class PhoneNumberForm < QuestionsForm
  set_attributes_for :intake, :phone_number, :phone_number_confirmation, :phone_number_can_receive_texts
  validates :phone_number, phone: { message: "Please enter a valid phone number." }
  validates :phone_number, confirmation: { message: "Please double check that the phone numbers match." }
  validates :phone_number_confirmation, presence: true

  def save
    @intake.update(attributes_for(:intake).except(:phone_number_confirmation))
  end
end
