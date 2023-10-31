module StateFile
  module StartIntakeConcern
    # This concern can be included in the first controller in a
    # navigation flow that needs to create an intake.
    # It depends on having access to a question_navigator method.
    extend ActiveSupport::Concern

    private
    def current_intake
      @intake ||= question_navigator.intake_class.new(
        visitor_id: cookies.encrypted[:visitor_id],
        source: session[:source],
        referrer: session[:referrer]
      )
    end

    def after_update_success
      session[:state_file_intake] = current_intake.to_global_id
    end
  end
end