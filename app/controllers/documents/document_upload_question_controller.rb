module Documents
  class DocumentUploadQuestionController < Questions::QuestionsController
    layout "document_upload"

    delegate :document_type, to: :class
    helper_method :document_type

    def edit
      return if self.class.document_type.nil?

      @documents = current_intake.documents.of_type(document_type)
      @form ||= form_class.new(document_type, current_intake, form_params)
    end

    def update
      return if self.class.document_type.nil?

      @form = form_class.new(document_type, current_intake, form_params)
      if @form.valid?
        @form.save
        after_update_success
        track_document_upload
        if @form.try(:next_step)
          redirect_to next_path and return
        end
      end

      edit
      render :edit
    end

    private

    def form_name
      self.class.form_class.name.underscore
    end

    def self.form_class
      if DocumentNavigation::REQUIRED_DOCUMENT_TYPES.include?(document_type)
        RequiredDocumentUploadForm
      else
        DocumentTypeUploadForm
      end
    end

    def self.document_type
      raise NotImplementedError, "#{self.name} must implement document_type or return nil to indicate no document will be uploaded."
    end

    def track_document_upload
      return unless @form.document.present?

      send_mixpanel_event(event_name: "document_uploaded", data: {
        document_type: document_type,
        file_extension: File.extname(@form.document.original_filename),
        file_content_type: @form.document.content_type,
      })
    end

    def next_path(params = {})
      next_step = form_navigation.next_for_intake(current_intake)
      document_path(next_step.to_param, params) if next_step
    end

    def current_path(params = {})
      document_path(self.class.to_param, params)
    end

    def form_navigation
      @form_navigation ||= DocumentNavigation.new(self)
    end
  end
end
