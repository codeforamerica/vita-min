module GyrDocuments
  def self.has_all_required_docs?(intake)
    submitted_doc_types = intake.documents.pluck(:document_type)

    has_photo_id = DocumentTypes::IDENTITY_TYPES.map(&:key).
      intersect?(submitted_doc_types)
    has_2ndary_id = DocumentTypes::SECONDARY_IDENTITY_TYPES.map(&:key).
      intersect?(submitted_doc_types)

    has_photo_id && has_2ndary_id &&
      (IdVerificationExperimentService.new(current_intake).skip_selfies? ||
        submitted_doc_types.include?(DocumentTypes::Selfie.key))
  end
end
