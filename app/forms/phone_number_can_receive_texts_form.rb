class PhoneNumberCanReceiveTextsForm < QuestionsForm
  set_attributes_for :intake, :phone_number_can_receive_texts

  def save
    attributes = attributes_for(:intake)
    if phone_number_can_receive_texts == "yes"
      attributes[:sms_phone_number] = @intake.phone_number
    elsif phone_number_can_receive_texts == "no" && (@intake.phone_number == @intake.sms_phone_number)
      attributes[:sms_phone_number] = nil
      attributes[:sms_phone_number_verified_at] = nil
    end
    @intake.update(attributes)
  end
end