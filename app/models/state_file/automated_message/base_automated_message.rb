module StateFile::AutomatedMessage
  class BaseAutomatedMessage
    # indicate that you want to track sending and block duplicates from being sent.
    def self.send_only_once?
      false
    end

    def self.after_transition_notification?
      false
    end

    # Convenience methods for time
    def tax_deadline = Rails.application.config.tax_deadline
    def end_of_login = Rails.configuration.end_of_login

    def app_time(body_args)
      body_args.fetch(:app_time, Time.current).to_datetime
    end
  end
end
