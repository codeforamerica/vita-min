module Documents
  class EmploymentController < DocumentUploadQuestionController
    class << self
      def document_type
        DocumentTypes::Employment
      end

      def displayed_document_types
        %w[W-2 1099-K 1099-MISC Employment]
      end
    end
  end
end
