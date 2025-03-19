module Questions
  class MailingAddressController < QuestionsController
    include AuthenticatedClientConcern

    def tracking_data
      {}
    end

    def after_update_success
      GenerateF13614cPdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
    end

    def next_path
      next_step = Navigation::DocumentNavigation.first_for_intake(current_intake)
      document_path(next_step.to_param)
    end
  end
end
