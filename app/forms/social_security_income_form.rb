class SocialSecurityIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_social_security_income

  def save
    @intake.update(attributes_for(:intake))
  end
end