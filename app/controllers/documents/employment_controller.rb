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

    private

    def after_update_success
      current_intake.advance_tax_return_statuses_to("intake_open") if current_intake.ready_for_open_status?
    end
  end
end
