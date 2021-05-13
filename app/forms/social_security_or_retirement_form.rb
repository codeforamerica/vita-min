class SocialSecurityOrRetirementForm < QuestionsForm
  set_attributes_for :intake, :had_social_security_or_retirement

  def save
    if had_social_security_or_retirement == "yes"
      @intake.update(attributes_for(:intake))
    else
      @intake.update(attributes_for(:intake).merge(gated_answers))
    end
  end

  private

  def gated_answers
    Hash[gated_questions.map { |question| [question, "no"] }]
  end

  def gated_questions
    [:had_social_security_income, :had_retirement_income, :paid_retirement_contributions]
  end
end