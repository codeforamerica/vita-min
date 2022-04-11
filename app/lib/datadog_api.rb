module DatadogApi
  METRIC_TYPES = {
    count: "count".freeze,
    gauge: "gauge".freeze,
    rate: "rate".freeze,
  }.freeze

  class Configuration
    def env
      Rails.env
    end

    def api_key
      Rails.application.credentials.dig(:datadog_api_key)
    end

    def namespace
      "vita-min.dogapi"
    end

    def enabled
      Rails.env.staging? || Rails.env.demo? || Rails.env.production?
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.client
    @dogapi_client ||= Dogapi::Client.new(configuration.api_key)
  end

  def self.apply_namespace(label)
    unless configuration.namespace.empty?
      configuration.namespace + '.' + label
    end
  end

  def self.increment(label, tags: [])
    return unless configuration.enabled

    future = emit_point(label: label, tags: tags, value: 1, type: METRIC_TYPES[:count])
    @synchronous ? future.value! : future
  end

  def self.gauge(label, value, tags: [])
    return unless configuration.enabled

    future = emit_point(label: label, tags: tags, value: value, type: METRIC_TYPES[:gauge])
    @synchronous ? future.value! : future
  end

  def self.emit_point(label:, tags:, value:, type:)
    tags << "env:#{configuration.env}"
    Concurrent::Future.execute do
      self.client.emit_point(self.apply_namespace(label), value, { tags: tags, type: type })
    end
  end
  private_class_method :emit_point
end
