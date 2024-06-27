module StateFile
  class EsignDeclarationForm < QuestionsForm
    set_attributes_for :state_file_efile_device_info, :device_id
    set_attributes_for :intake,
                       :primary_esigned,
                       :spouse_esigned

    validates :primary_esigned, acceptance: { accept: 'yes', message: ->(_object, _data) { I18n.t("views.ctc.questions.confirm_legal.error") }}
    validates :spouse_esigned, acceptance: { accept: 'yes', message: ->(_object, _data) { I18n.t("views.ctc.questions.confirm_legal.error") }}, if: -> { @intake.ask_spouse_esign? }
    validate :validate_intake_already_submitted

    def save
      return false unless valid?
      attrs = @intake.ask_spouse_esign? ? attributes_for(:intake) : attributes_for(:intake).except(:spouse_esigned)
      @intake.update!(attrs)
      @intake.touch(:primary_esigned_at) if @intake.primary_esigned_yes?
      @intake.touch(:spouse_esigned_at) if @intake.spouse_esigned_yes? && @intake.ask_spouse_esign?

      efile_info = StateFileEfileDeviceInfo.find_by(event_type: "submission", intake: @intake)
      efile_info&.update!(attributes_for(:state_file_efile_device_info))

      old_efile_submission = @intake.efile_submissions&.last
      if old_efile_submission.present?
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
      if Flipper.enabled?(:prevent_duplicate_accepted_statefile_submissions)
        return true if accepted_submissions_with_same_ssn(@intake).any?
      end
      current_state = @intake.efile_submissions.last&.current_state
      return true if ["rejected", "notified_of_rejection", "waiting", nil].exclude?(current_state)
      false
    end

    def validate_intake_already_submitted
      if intake_already_submitted?
        self.errors.add(:base, :already_submitted, message: I18n.t("state_file.questions.esign_declaration.edit.already_submitted"))
      end
    end
  end
end