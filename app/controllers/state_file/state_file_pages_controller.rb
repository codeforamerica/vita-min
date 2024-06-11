module StateFile
  class StateFilePagesController < ApplicationController
    layout "state_file"
    before_action :redirect_state_file_in_off_season, except: [:coming_soon]

    def redirect_locale_home
      redirect_to root_path
    end

    def fake_direct_file_transfer_page
      return render "public_pages/page_not_found", status: 404 if Rails.env.production?

      @main_transfer_url = transfer_url("abcdefg", params[:redirect])
      @xml_samples = XmlReturnSampleService.new.samples.map do |sample|
        [sample.label, transfer_url(sample.key, params[:redirect])]
      end.sort
      render layout: nil
    end

    def data_import_failed; end

    def about_page; end

    def privacy_policy; end

    def coming_soon
      redirect_to root_path unless before_state_file_launch?
    end

    def clear_session
      session.delete(:state_file_intake)
      redirect_to action: :about_page
    end

    def login_options
      @sign_in_closed = app_time.after?(Rails.configuration.state_file_end_of_in_progress_intakes)
    end

    private

    def transfer_url(key, redirect_url)
      uri = URI(redirect_url)
      uri.query = { authorizationCode: key }.to_query
      uri.to_s
    end

    def current_intake
      @current_intake ||= (
        StateFile::StateInformationService::ACTIVE_STATES
          .lazy
          .map{|c| send("current_state_file_#{c}_intake".to_sym) }
          .find(&:itself)
      )
    end
  end
end
