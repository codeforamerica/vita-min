module StateFile
  module StartIntakeConcern
    # This concern can be included in the first controller in a
    # navigation flow that needs to create an intake.
    # It depends on having access to a question_navigator method.
    # The page where this is used needs to be making a post request to update,
    # as this concern relies on after_update_success being called.
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
      current_intake.save unless current_intake.persisted?
      session[:state_file_intake] = current_intake.to_global_id
    end
  end
end