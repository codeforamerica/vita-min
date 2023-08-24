class IssuedIdentityPinForm < QuestionsForm
  set_attributes_for :intake, :issued_identity_pin

  def save
    @intake.update(attributes_for(:intake))
  end
end