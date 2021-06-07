module Documents
  class OverviewController < DocumentUploadQuestionController
    layout "intake"

    helper_method :document_type_keys

    def edit
      @documents = current_intake.documents
    end

    def self.document_type
      nil
    end

    private

    # this list will include all types that are relevant to the intake (based on answers)
    # plus requested documents if any have been uploaded
    def document_type_keys
      document_types = current_intake.relevant_intake_document_types.map(&:key)
      include_requested_documents = @documents.where(document_type: "Requested").exists?
      document_types += ["Requested"] if include_requested_documents
      document_types
    end

    def illustration_path
      "documents.svg"
    end
  end
end
