module StateFile
  module Questions
    class LandingPageController < QuestionsController
      skip_before_action :redirect_if_no_intake
      skip_before_action :set_current_step

      def edit
        @state_name = StateFileBaseIntake::STATE_CODE_AND_NAMES[params[:us_state]]
        @closed = app_time.after?(Rails.configuration.state_file_end_of_in_progress_intakes)
        if current_intake.present?
          if current_intake.primary_first_name.present?
            @user_name = current_intake.primary_first_name
          end
        end
      end

      def update
        StateFileBaseIntake::STATE_CODES.each do |state_code|
          intake = send("current_state_file_#{state_code}_intake")
          sign_out intake if intake
        end
        intake = question_navigator.intake_class.new(
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
