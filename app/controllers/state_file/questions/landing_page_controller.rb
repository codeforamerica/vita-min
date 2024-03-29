module StateFile
  module Questions
    class LandingPageController < QuestionsController
      skip_before_action :redirect_if_no_intake

      def edit
        @state_name = StateFileBaseIntake::STATE_CODE_AND_NAMES[params[:us_state]]
        if current_intake.present?
          if current_intake.primary_first_name.present?
            @user_name = "#{current_intake.primary_first_name} #{current_intake.primary_middle_initial} #{current_intake.primary_last_name}"
          elsif current_intake.raw_direct_file_data.present?
            begin
              @user_name = current_intake.direct_file_data.node.at("Filer NameLine1Txt").text.gsub("&lt;", " ")
            rescue => err
              Rails.logger.error(err)
            end
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
        sign_in intake
        redirect_to next_path
      end
    end
  end
end
