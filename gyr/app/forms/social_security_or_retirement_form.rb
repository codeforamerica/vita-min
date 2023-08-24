class SocialSecurityOrRetirementForm < QuestionsForm
  set_attributes_for :intake, :had_social_security_or_retirement

  def save
    @intake.update(attributes_for(:intake))
  end
end