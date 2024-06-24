module Questions
  class FinalInfoController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    private

    def after_update_success
      current_intake.update(completed_at: Time.now)
      GenerateF13614cPdfJob.perform_later(current_intake.id, "Original 13614-C.pdf")

      MixpanelService.send_event(
        distinct_id: current_intake.visitor_id,
        event_name: "intake_finished",
        data: MixpanelService.data_from([current_intake.client, current_intake])
      )
      send_confirmation_message
    end

    def tracking_data
      {}
    end

    def send_confirmation_message
      @client = current_intake.client
      tax_deadline = Rails.configuration.tax_deadline
      end_of_in_progress_intake = Rails.configuration.end_of_in_progress_intake
      doc_submission_deadline = Rails.configuration.doc_submission_deadline
      end_of_docs_date = Rails.configuration.end_of_docs.to_date

      doc_date = if app_time.before?(tax_deadline) || app_time.after?(end_of_in_progress_intake)
                   doc_submission_deadline
                 else
                   end_of_docs_date
                 end
      
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: current_intake.client,
        message: AutomatedMessage::SuccessfulSubmissionOnlineIntake,
        locale: I18n.locale,
        body_args: { end_of_docs_date: I18n.l(doc_date, format: :medium, locale: I18n.locale, default: "%B %-d") }
      )
    end
  end
end
