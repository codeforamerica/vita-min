class PhoneNumberForm < QuestionsForm
  set_attributes_for :intake, :phone_number, :phone_number_confirmation, :phone_number_can_receive_texts
  validates :phone_number, phone: { message: "Please enter a valid phone number." }
  validates :phone_number, confirmation: { message: "Please double check that the phone numbers match." }
  validates :phone_number_confirmation, presence: true

  # def phone_number=(value)
  #   if value.present? && value.is_a?(String)
  #     unless value[0] == "1" || value[0..1] == "+1"
  #       value = "1#{value}" # add USA country code
  #     end
  #     @intake.assign_attributes(phone_number: Phonelib.parse(value).sanitized) if @intake
  #   else
  #     @intake.assign_attributes(phone_number: value) if @intake
  #   end
  # end

  def save
    @intake.update(attributes_for(:intake).except(:phone_number_confirmation))
  end
end
