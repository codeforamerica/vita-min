module StateFile
  class StateFilePagesController < ApplicationController
    layout "state_file"
    before_action :redirect_state_file_in_off_season, only: [:about_page]

    def redirect_locale_home
      redirect_to root_path
    end

    def fake_direct_file_transfer_page
      @main_transfer_url = transfer_url("abcdefg", params[:redirect])
      @xml_samples = XmlReturnSampleService.new.samples.map do |sample|
        [sample.label, transfer_url(sample.key, params[:redirect])]
      end.sort
      render layout: nil
    end

    def about_page; end

    def privacy_policy; end

    def coming_soon
      redirect_to root_path unless before_state_file_launch?
    end

    def clear_session
      session.delete(:state_file_intake)
      redirect_to action: :about_page
    end

    def login_options; end

    private

    def transfer_url(key, redirect_url)
      uri = URI(redirect_url)
      uri.query = { authorizationCode: key }.to_query
      uri.to_s
    end
  end
end
