require 'datadog/statsd'

module DatadogMetrics

  class Configuration
    attr_accessor :enabled, :host, :port, :namespace
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

  def self.statsd
    @statsd ||= Datadog::Statsd.new(configuration.host, configuration.port, logger: Rails.logger, namespace: configuration.namespace)
  end

  def self.statsd_gauge(label, value)
    return unless configuration.enabled

    statsd.gauge(label, value)
  end

  def self.statsd_increment(label)
    return unless configuration.enabled

    statsd.increment(label)
  end

end
