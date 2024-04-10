require 'rails_helper'

describe MixpanelService do
  before do
    allow(Rails.env).to receive(:development?).and_return(false)
    allow(Rails.application.credentials).to receive(:dig).and_return("mock-mixpanel-token")
  end

  xcontext "when the TCP connection is fine" do
    it 'tries 1 time' do
      expect(MixpanelService.instance.instance_variable_get(:@consumer)).to receive(:send!).exactly(1).times
      allow(Concurrent::ScheduledTask).to receive(:new) { |delay, &block| MockScheduledTask.new(delay, &block) }
      MixpanelService.send_event(distinct_id: 'distinct_id', event_name: 'event_name', data: {})
    end
  end

  xcontext "when the TCP connection fails" do
    it 'tries 3 times' do
      expect(MixpanelService.instance.instance_variable_get(:@consumer)).to receive(:send!).exactly(3).times.and_raise(StandardError)
      allow(Concurrent::ScheduledTask).to receive(:new) { |delay, &block| MockScheduledTask.new(delay, &block) }
      MixpanelService.send_event(distinct_id: 'distinct_id', event_name: 'event_name', data: {})
    end
  end
end


# Mock scheduled task executes in the current thread
class MockScheduledTask
  def initialize(delay, &block)
    @block = block
  end

  def execute
    @block.call
  end
end
