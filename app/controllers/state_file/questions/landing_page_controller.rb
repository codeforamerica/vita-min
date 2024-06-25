module StateFile
  module Questions
    class LandingPageController < QuestionsController
      skip_before_action :redirect_if_no_intake
      skip_before_action :set_current_step
      skip_before_action :redirect_if_in_progress_intakes_ended

      def edit
        @closed = app_time.after?(Rails.configuration.state_file_end_of_in_progress_intakes)
        if current_intake.present?
          if current_intake.primary_first_name.present?
            @user_name = current_intake.primary_first_name
          end
        end
      end

      def update
        sign_out current_intake if current_intake
        intake = StateInformationService.intake_class(current_state_code).new(
          visitor_id: cookies.encrypted[:visitor_id],
          source: session[:source],
          referrer: session[:referrer]
        )
        intake.save
        intake.create_state_file_analytics!
        sign_in intake
        redirect_to next_path
      end
    end
  end
end
