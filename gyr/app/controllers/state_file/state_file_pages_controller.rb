module StateFile
  class StateFilePagesController < ApplicationController
    layout "state_file"

    def redirect_locale_home
      redirect_to root_path
    end

    def home
    end
  end
end
