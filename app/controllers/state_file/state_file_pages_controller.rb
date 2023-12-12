module StateFile
  class StateFilePagesController < ApplicationController
    layout "state_file"

    def redirect_locale_home
      redirect_to root_path
    end

    def fake_direct_file_transfer_page
      render layout: nil
    end

    def about_page; end

    def clear_session
      session.delete(:state_file_intake)
      redirect_to action: :about_page
    end

    def login_options; end
  end
end
