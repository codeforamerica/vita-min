class TriageIncomeLevelForm < Form
  include FormAttributes
  set_attributes_for :triage, :income_level, :source, :referrer, :locale, :visitor_id
  attr_reader :triage

  def save
    @triage = Triage.create!(attributes_for(:triage))
  end
end
