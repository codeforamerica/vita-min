class TriageDocTypeForm < TriageForm
  include FormAttributes
  set_attributes_for :triage, :doc_type

  validates_presence_of :doc_type
end
