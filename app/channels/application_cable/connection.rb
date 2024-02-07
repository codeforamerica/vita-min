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
      return @current_state_file_intake if @current_state_file_intake
      model_key = @request.session.keys.detect do |key|
        key.starts_with?("warden.user.") && key.ends_with?(".key")
      end
      model_id = @request.session[model_key].first.first
      model_name = model_key.delete_prefix("warden.user.").delete_suffix(".key")
      model_class = model_name.camelize.constantize
      @current_state_file_intake = model_class.find(model_id)
      @current_state_file_intake
    rescue
      DatadogApi.increment "application_cable.uncaught_throw_warden_error"
    end
  end
end
