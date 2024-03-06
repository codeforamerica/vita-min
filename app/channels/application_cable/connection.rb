module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_state_file_intake
    rescue_from StandardError, with: :report_error
    rescue_from ActionCable::Connection::Authorization::UnauthorizedError, with: report_error

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
      warden = env['warden']
      @current_state_file_intake = StateFileBaseIntake::STATE_CODES.lazy.map{|c| warden.user("state_file_#{c}_intake".to_sym) }.find(&:itself)
    rescue UncaughtThrowError => e
      raise unless e.tag == :warden

      # 'uncaught throw :warden' is fired in certain circumstances, this here is to silence it
      DatadogApi.increment "application_cable.uncaught_throw_warden_error"
      reject_unauthorized_connection
    end

    def report_error(e)
      Rails.logger.warn ([e.message]+e.backtrace).join($/)
    end
  end
end
