class EipOverviewForm < QuestionsForm
  set_attributes_for :intake, :eip_only, :source, :referrer, :locale, :visitor_id

  def save
    @intake.update(attributes_for(:intake).merge(client: client))
  end

  private

  def client
    @intake.client || Client.create!
  end
end
