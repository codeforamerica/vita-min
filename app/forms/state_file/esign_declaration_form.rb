module StateFile
  class EsignDeclarationForm < QuestionsForm
    set_attributes_for :state_file_efile_device_info, :device_id
    set_attributes_for :intake,
                       :primary_esigned,
                       :spouse_esigned,
                       :primary_signature_pin,
                       :spouse_signature_pin

    validates :primary_esigned, acceptance: { accept: 'yes', message: ->(_object, _data) { I18n.t("views.ctc.questions.confirm_legal.error") }}
    validates :spouse_esigned, acceptance: { accept: 'yes', message: ->(_object, _data) { I18n.t("views.ctc.questions.confirm_legal.error") }}, if: -> { @intake.ask_spouse_esign? }
    validate :validate_intake_already_submitted
    validates :primary_signature_pin, presence: true, signature_pin: true, if: -> { @intake.ask_for_signature_pin? }
    validates :spouse_signature_pin, presence: true, signature_pin: true, if: -> { @intake.ask_for_signature_pin?  && @intake.ask_spouse_esign? }

    def save
      return false unless valid?
      attrs = attributes_for(:intake)
      spouse_esigned = @intake.ask_spouse_esign?
      signature_pin_needed = @intake.ask_for_signature_pin?

      attrs.except!(:spouse_esigned) unless spouse_esigned
      attrs.except!(:primary_signature_pin, :spouse_signature_pin) unless signature_pin_needed
      attrs.except!(:spouse_signature_pin) unless spouse_esigned && signature_pin_needed

      if @intake.ask_for_signature_pin?
        attrs[:primary_signature_pin] = primary_signature_pin
        attrs[:spouse_signature_pin] = spouse_signature_pin
      end

      @intake.update!(attrs)
      @intake.touch(:primary_esigned_at) if @intake.primary_esigned_yes?
      @intake.touch(:spouse_esigned_at) if @intake.spouse_esigned_yes? && @intake.ask_spouse_esign?

      efile_info = StateFileEfileDeviceInfo.find_by(event_type: "submission", intake: @intake)
      efile_info&.update!(attributes_for(:state_file_efile_device_info))

      old_efile_submission = @intake.efile_submissions&.last
      if old_efile_submission.present?
        # we need to detach the existing submission PDF from the intake to avoid it being briefly accessible
        # from the /submission-confirmation page while the new PDF is being generated & attached.
        # See https://github.com/codeforamerica/vita-min/pull/5282 for more details
        @intake.submission_pdf.detach

        # the after_transitions :resubmission creates a new efile submission and transitions it to :preparing
        old_efile_submission.transition_to!(:resubmitted) if ["rejected", "notified_of_rejection", "waiting"].include?(old_efile_submission.current_state)
      else
        # Submits new return
        new_efile_submission = EfileSubmission.create!(data_source: @intake)

        begin
          new_efile_submission.transition_to(:preparing) # will start the process of submitting the return
        rescue Statesman::GuardFailedError
          Rails.logger.error "Failed to transition EfileSubmission##{new_efile_submission.id} to :preparing"
        end
      end
    end

    def accepted_submissions_with_same_ssn(intake)
      table_name = intake.class.table_name
      class_name = intake.class.name
      EfileSubmission
        .joins("INNER JOIN #{table_name} ON efile_submissions.data_source_type='#{class_name}' AND efile_submissions.data_source_id = #{table_name}.id")
        .where(table_name => { hashed_ssn: intake.hashed_ssn })
        .joins(:efile_submission_transitions)
        .where(efile_submission_transitions: { to_state: [
          :accepted,
          :new,
          :preparing,
          :bundling,
          :queued,
          :transmitted,
          :ready_for_ack
        ], most_recent: true })
    end

    def intake_already_submitted?
      if Rails.env.development? || Rails.env.heroku? || Rails.env.demo?
        return false
      end
      if Flipper.enabled?(:prevent_duplicate_accepted_statefile_submissions)
        return true if accepted_submissions_with_same_ssn(@intake).any?
      end
      current_state = @intake.efile_submissions.last&.current_state
      ["rejected", "notified_of_rejection", "waiting", nil].exclude?(current_state)
    end

    def validate_intake_already_submitted
      if intake_already_submitted?
        self.errors.add(:base, :already_submitted, message: I18n.t("state_file.questions.esign_declaration.edit.already_submitted"))
      end
    end
  end
end