module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      reject_unauthorized_connection if current_user.blank?
    end

    def current_user
      @current_user ||= env['warden'].user
    end
  end
end
