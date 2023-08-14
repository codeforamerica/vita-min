# frozen_string_literal: true

class WorkerHeartbeatJob < ApplicationJob
  self.retry_jitter = 0
  def perform(time_enqueued_secs)
    DatadogApi.gauge("worker_heartbeat.latency", Time.current.to_i - time_enqueued_secs)
  end
end
