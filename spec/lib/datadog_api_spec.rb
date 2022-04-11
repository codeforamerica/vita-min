require 'rails_helper'

describe DatadogApi do
  include MockDogapi

  before do
    DatadogApi.configure do |c|
      allow(c).to receive(:namespace).and_return("test.dogapi")
    end
  end

  context "when enabled" do
    before do
      DatadogApi.configure do |c|
        allow(c).to receive(:enabled).and_return(true)
      end
    end

    it 'initializes and calls Dogapi::Client' do
      DatadogApi.gauge('volume', 11)
      DatadogApi.increment('counter')

      expect(Dogapi::Client).to have_received(:new).once
      expect(@mock_dogapi).to have_received(:emit_point).once.with('test.dogapi.volume', 11, {:tags => ["env:"+Rails.env], :type => "gauge"})
      expect(@mock_dogapi).to have_received(:emit_point).once.with('test.dogapi.counter', 1, {:tags => ["env:"+Rails.env], :type => "count"})
    end
  end

  context "when disabled" do
    before do
      DatadogApi.configure do |c|
        allow(c).to receive(:enabled).and_return(false)
      end
    end

    it 'does not initialize and call Dogapi::Client' do
      DatadogApi.gauge('volume', 11)
      DatadogApi.increment('counter')

      expect(Dogapi::Client).not_to have_received(:new)
      expect(@mock_dogapi).not_to have_received(:emit_point)
    end
  end
end
