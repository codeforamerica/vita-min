module Middleware
  class CleanupRequestHostHeaders
    def initialize(app)
      @app = app
    end

    def call(env)
      # Filter out client-submitted "X-Forwarded-Host" headers; Rails trusts them but
      # our deployment on Aptible does not send them.
      #
      # Similar to https://github.com/pusher/rack-headers_filter but retains all the headers
      # Aptible does actually send: https://deploy-docs.aptible.com/docs/http-request-headers
      @app.call(env)
    end
  end
end
