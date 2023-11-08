module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_state_file_intake

    def connect; end

    def current_user
      @current_user ||= env['warden'].user
    rescue UncaughtThrowError => e
      raise unless e.tag == :warden

      # 'uncaught throw :warden' is fired in certain circumstances, this here is to silence it
      DatadogApi.increment "application_cable.uncaught_throw_warden_error"
      reject_unauthorized_connection
    end

    def current_state_file_intake
      GlobalID.find(@request.session[:state_file_intake])
    end
  end
end
