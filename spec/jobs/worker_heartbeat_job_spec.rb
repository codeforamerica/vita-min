# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkerHeartbeatJob, active_job: true do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe "#perform" do
    before do
      allow(DatadogApi).to receive(:gauge)
    end

    it "updates gauge with delta of enqueue time" do
      described_class.new.perform(30.seconds.ago.to_i)
      expect(DatadogApi).to have_received(:gauge).with("worker_heartbeat.latency", 30)
    end
  end

end
