require 'dogapi'

module DatadogApi

  METRIC_TYPES = {
      count: "count".freeze,
      gauge: "gauge".freeze,
      rate: "rate".freeze,
  }.freeze

  class Configuration
    attr_accessor :enabled, :env, :api_key, :namespace
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
    @statsd ||= Dogapi::Client.new(configuration.api_key)
  end

  def self.apply_namespace(label)
    unless configuration.namespace.empty?
      configuration.namespace + '.' + label
    end
  end

  def self.increment(label)
    return unless configuration.enabled

    self.client.emit_point(self.apply_namespace(label), 1, {:tags => ["env:" + configuration.env], :type => METRIC_TYPES[:count]})
  end

  def self.gauge(label, value)
    return unless configuration.enabled

    self.client.emit_point(self.apply_namespace(label), value, {:tags => ["env:" + configuration.env], :type => METRIC_TYPES[:gauge]})
  end
end
