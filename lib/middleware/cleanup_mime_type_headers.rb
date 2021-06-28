module Middleware
  class CleanupMimeTypeHeaders
    def initialize(app)
      @app = app
    end

    def call(env)
      # Filter out invalid "Accept" or "Content-Type" headers to avoid noisy logs.
      # https://github.com/rails/rails/issues/37620
      clean_header!(env, 'CONTENT_TYPE')
      clean_header!(env, 'HTTP_ACCEPT')
      @app.call(env)
    end

    def clean_header!(env, header_name)
      return unless env.key?(header_name)

      Mime::Type.parse(env.dig(header_name))
    rescue Mime::Type::InvalidMimeType
      env.store(header_name, 'unknown/unknown')
    end
  end
end
