require 'rails_helper'

describe DatadogApi do
  let(:mock_dogapi) { instance_double(Dogapi::Client, emit_point: nil) }

  before do
    allow(Dogapi::Client).to receive(:new).and_return(mock_dogapi)
  end

  it 'initializes and calls Dogapi::Client when enabled' do
    DatadogApi.configure do |c|
      c.enabled = true
      c.namespace = "test.dogapi"
    end

    DatadogApi.gauge('volume', 11)
    DatadogApi.increment('counter')

    expect(Dogapi::Client).to have_received(:new).once
    expect(mock_dogapi).to have_received(:emit_point).once.with('test.dogapi.volume', 11, {:tags => ["env:"+Rails.env], :type => "gauge"})
    expect(mock_dogapi).to have_received(:emit_point).once.with('test.dogapi.counter', 1, {:tags => ["env:"+Rails.env], :type => "count"})
  end

  it 'does not initialize and call Dogapi::Client when disabled' do
    DatadogApi.configure do |c|
      c.enabled = false
    end

    DatadogApi.gauge('volume', 11)
    DatadogApi.increment('counter')

    expect(Dogapi::Client).not_to have_received(:new)
    expect(mock_dogapi).not_to have_received(:emit_point)
  end
end
