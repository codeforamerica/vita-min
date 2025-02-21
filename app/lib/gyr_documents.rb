module GyrDocuments
  def has_all_required_docs?(intake)
    intake_doc_types = intake.documents.pluck(:document_type)
    required_docs = []
    required_docs << DocumentTypes::Selfie.key unless IdVerificationExperimentService.new(intake).skip_selfies?
    DocumentTypes::IDENTITY_TYPES.map(&:key).intersect?(intake_doc_types) &&
      DocumentTypes::SECONDARY_IDENTITY_TYPES.map(&:key).intersect?(intake_doc_types) &&
      required_docs.all? {|key| intake_doc_types.include?(key) }
  end

  def advance_to(intake, next_state)
    intake.tax_returns.each do |tax_return|
      tax_return.transition_to(next_state) if tax_return.current_state.to_sym != next_state
    end
  end
end
