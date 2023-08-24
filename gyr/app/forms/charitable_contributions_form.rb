class CharitableContributionsForm < QuestionsForm
  set_attributes_for :intake, :paid_charitable_contributions

  def save
    @intake.update(attributes_for(:intake))
  end
end