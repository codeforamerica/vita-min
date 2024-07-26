module StateFile
  class LandingPageController < ApplicationController
    include StateFile::StateFileControllerConcern
    include StateFile::StateFileIntakeConcern
    helper_method :prev_path, :illustration_path
    layout "state_file"

    before_action :require_state_file_intake_login, except: [:edit, :update]

    def edit
      @closed = app_time.after?(Rails.configuration.state_file_end_of_in_progress_intakes)
      if current_intake.present?
        if current_intake.primary_first_name.present?
          @user_name = current_intake.primary_first_name
        end
      end
      @state_code = params[:us_state]
      @state_name = StateFile::StateInformationService.state_name(@state_code)
    end

    def update
      binding.pry

      sign_out current_intake if current_intake.present?
      intake = StateInformationService.intake_class(params[:us_state]).new(
        visitor_id: cookies.encrypted[:visitor_id],
        source: session[:source],
        referrer: session[:referrer]
      )
      intake.save
      intake.create_state_file_analytics!
      sign_in intake

      navigation = StateFile::StateInformationService.navigation_class(params[:us_state])
      redirect_to navigation.controllers.first.to_path_helper
    end

    private

    def prev_path; end

    def illustration_path; end

  end
end
