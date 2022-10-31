module Documents
  class SsnItinsController < DocumentUploadQuestionController
    before_action :set_household_names, only: [:edit, :update]

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
      [DocumentTypes::Identity.key, DocumentTypes::Selfie.key, DocumentTypes::SsnItin.key].all? do |key|
        current_intake.documents.pluck(:document_type).include?(key)
      end
    end

    def set_household_names
      @names = [current_intake.primary.first_and_last_name]
      if current_intake.filing_joint_yes?
        @names << current_intake.spouse_name_or_placeholder
      end
      if current_intake.dependents.present?
        @names += current_intake.dependents.map(&:full_name)
      end
    end
  end
end
