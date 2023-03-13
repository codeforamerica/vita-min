module Documents
  class SsnItinsController < DocumentUploadQuestionController
    before_action :set_required_person_names, only: [:edit, :update]

    def self.document_type
      DocumentTypes::SsnItin
    end

    def after_update_success
      transition_to = has_all_required_docs? ? :intake_ready : :intake_needs_doc_help
      current_intake.tax_returns.each do |tax_return|
        tax_return.transition_to(transition_to) if tax_return.current_state.to_sym != transition_to
      end
    end

    private

    def has_all_required_docs?
      intake_doc_types = current_intake.documents.pluck(:document_type)
      requires_one_of = DocumentTypes::IDENTITY_TYPES.map(&:key)
      required_docs = [DocumentTypes::SsnItin.key]
      required_docs << DocumentTypes::Selfie.key unless IdVerificationExperimentService.new(current_intake).skip_selfies?
      requires_one_of.intersect?(intake_doc_types) && required_docs.all? {|key| intake_doc_types.include?(key) }
    end
  end
end
