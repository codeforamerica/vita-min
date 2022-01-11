class TriageForm < Form
  include FormAttributes
  attr_reader :triage

  def self.from_record(triage)
    new(triage, existing_attributes(triage, Attributes.new(scoped_attributes[:triage]).to_sym))
  end

  def self.existing_attributes(model, attribute_keys)
    HashWithIndifferentAccess[(attribute_keys || []).map { |k| [k, model.send(k)] }]
  end

  def initialize(record, params = {})
    @triage = record
    super(params)
  end

  def save
    if triage
      triage.update!(attributes_for(:triage))
    else
      Triage.create!(attributes_for(:triage))
    end
  end
end
