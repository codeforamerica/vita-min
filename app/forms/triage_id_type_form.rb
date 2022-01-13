class TriageIdTypeForm < TriageForm
  include FormAttributes
  set_attributes_for :triage, :id_type

  validates_presence_of :id_type
end
