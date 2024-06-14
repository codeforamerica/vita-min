module StateFile
  class StateFilePagesController < ApplicationController
    include StateFile::StateFileControllerConcern
    layout "state_file"
    before_action :redirect_state_file_in_off_season, except: [:coming_soon]

    def redirect_locale_home
      redirect_to root_path
    end

    def fake_direct_file_transfer_page
      return render "public_pages/page_not_found", status: 404 if Rails.env.production?

      @main_transfer_url = transfer_url("abcdefg", params[:redirect])
      @xml_samples = []
      us_state = current_intake.state_code
      @xml_samples = XmlReturnSampleService.new.samples[us_state].map do |sample_name|
        key = XmlReturnSampleService.key(us_state, sample_name)
        label = XmlReturnSampleService.label(sample_name)
        [label, transfer_url(key, params[:redirect])]
      end
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
  end
end
