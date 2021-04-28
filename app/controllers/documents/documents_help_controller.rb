module Documents
  class DocumentsHelpController < DocumentUploadQuestionController
    layout "intake"

    def show
      @doc_type = params[:doc_type]
    end

    private

    def illustration_path; end

    def prev_path
      :back
    end
  end
end