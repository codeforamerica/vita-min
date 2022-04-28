module Middleware
  class RejectInvalidParams
    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      begin
        req.params
      rescue Rack::QueryParser::InvalidParameterError
        return [400, {"Content-Type": "text/plain"}, ["Bad params"]]
      end
      @app.call(env)
    end
  end
end
