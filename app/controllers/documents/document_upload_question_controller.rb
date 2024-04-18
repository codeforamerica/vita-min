module Documents
  class DocumentUploadQuestionController < Questions::QuestionsController
    include AuthenticatedClientConcern
    layout "document_upload"

    before_action :set_paper_trail_whodunnit

    delegate :document_type_key, to: :class
    delegate :document_type, to: :class
    helper_method :document_type
    helper_method :destroy_document_path

    def illustration_path; end

    def edit
      return if document_type.nil?

      @selectable_document_types = selectable_document_types
      @documents = documents
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
        render :create
      end
    end

    def destroy
      document = current_intake.documents.find_by(id: params[:id])

      if document.present?
        document.destroy

        redirect_to action: :edit
      else
        redirect_to overview_documents_path
      end
    end

    def self.show?(intake)
      return true if document_type.nil?

      document_type.needed_if_relevant? && document_type.relevant_to?(intake)
    end

    def self.document_type_key
      # Return nil key for controllers with nil document_type.
      document_type&.key
    end

    def form_navigation
      Navigation::DocumentNavigation.new(self)
    end

    private

    def documents
      current_intake.documents.of_type(self.class.displayed_document_types)
    end

    def destroy_document_path(document)
      self.class.to_path_helper(action: :destroy, id: document.id)
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
      return unless @form.upload.present?

      send_mixpanel_event(event_name: "document_uploaded", data: {
        document_type: document_type_key,
        file_extension: File.extname(@form.upload.original_filename),
        file_content_type: @form.upload.content_type,
      })
    end

    def current_path(params = {})
      document_path(self.class.to_param, params)
    end

    def selectable_document_types
    end

    def user_for_paper_trail
      current_client&.id
    end

    def set_required_person_names
      @names = self.class.document_type.required_persons(current_intake).map(&:first_and_last_name)
    end
  end
end
