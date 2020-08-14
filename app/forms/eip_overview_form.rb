class EipOverviewForm < QuestionsForm
  set_attributes_for :intake, :eip_only, :source, :referrer, :locale

  def save
    @intake.update(attributes_for(:intake))
  end
end