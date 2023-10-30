module StateFile
  module StartIntakeConcern
    extend ActiveSupport::Concern

    def current_intake
      @intake ||= intake_class.new(
        visitor_id: cookies.encrypted[:visitor_id],
        source: session[:source],
        referrer: session[:referrer]
      )
    end
  end
end