module Documents
  class DocumentUploadQuestionController < Questions::TicketedQuestionsController
    layout "document_upload"

    delegate :document_type_key, to: :class
    delegate :document_type, to: :class
    helper_method :document_type
    helper_method :destroy_document_path

    def edit
      return if document_type.nil?

      @documents = current_intake.documents.of_type(self.class.displayed_document_types)
      @form = form_class.new(document_type_key, current_intake, form_params)
    end

    def update
      return if document_type.nil?

      @form = form_class.new(document_type_key, current_intake, form_params)
      if @form.valid?
        form_saved = @form.save
        after_update_success
        track_document_upload
        redirect_to action: :edit
      else
        track_validation_error
        render :edit
      end
    end

    def self.show?(intake)
      return true if document_type.nil?

      document_type.relevant_to? intake
    end

    def self.document_type_key
      # Return nil key for controllers with nil document_type.
      document_type&.key
    end

    private

    def destroy_document_path(document)
      document_path(document)
    end

    def form_name
      "document_type_upload_form"
    end

    def self.form_class
      DocumentTypeUploadForm
    end

    def self.document_type
      raise NotImplementedError, "#{self.name} must implement document_type or return nil to indicate no document will be uploaded."
    end

    def self.displayed_document_types
      [self.document_type_key]
    end

    def track_document_upload
      return unless @form.document.present?

      send_mixpanel_event(event_name: "document_uploaded", data: {
        document_type: document_type_key,
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

    def set_filer_names
      @names = [current_intake.primary_full_name]
      if current_intake.filing_joint_yes?
        @names << current_intake.spouse_name_or_placeholder
      end
    end
  end
end
