module Middleware
  class RejectBadlyEncodedHeaders
    def initialize(app)
      @app = app
    end

    def call(env)
      if valid_referer(env["HTTP_REFERER"])
        @app.call(env)
      else
        [400, {'Content-Type' => "text/plain"}, ["Bad header"]]
      end
    end

    private

    def valid_referer(header_value)
      return true if header_value.nil?
      return true if header_value.force_encoding("UTF-8").valid_encoding?
    end
  end
end
