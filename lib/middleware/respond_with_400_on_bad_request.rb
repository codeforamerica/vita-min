module Middleware
  class RespondWith400OnBadRequest
    def initialize(app)
      @app = app
    end

    def call(env)
      # Inspired by https://github.com/pulibrary/orangelight/pull/1409/files , call the part
      # of Rails that crashes with bad requests, and bubble it up to the website visitor
      # before calling into the rest of the app.
      begin
        ActionDispatch::Request.new(env.dup).params
      rescue ActionController::BadRequest
        return bad_request_response
      end
      @app.call(env)
    end

    private

    def bad_request_response
      bad_request_message = "Bad request"
      [400, {"Content-Type" => "text/plain", "Content-Length" => bad_request_message.size}, [bad_request_message]]
    end
  end
end
