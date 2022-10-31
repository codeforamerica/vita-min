module Documents
  class SelfiesController < DocumentUploadQuestionController
    before_action :set_filer_names, only: [:edit, :update]

    def self.document_type
      DocumentTypes::Selfie
    end

    def after_update_success
      current_intake.tax_returns.each do |tax_return|
        tax_return.advance_to(:intake_needs_doc_help)
      end
    end

    def illustration_path
      'ids.svg'
    end
  end
end
