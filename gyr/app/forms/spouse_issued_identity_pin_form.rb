class SpouseIssuedIdentityPinForm < QuestionsForm
  set_attributes_for :intake, :spouse_issued_identity_pin

  def save
    @intake.update(attributes_for(:intake))
  end
end