require 'rails_helper'

describe DatadogApi do
  include MockDogapi

  before do
    DatadogApi.instance_variable_set("@synchronous", false)
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

    it 'initializes and calls Dogapi::Client inside of a Promise' do
      gauge = DatadogApi.gauge('volume', 11)
      expect(gauge).to be_a Concurrent::Future
      gauge.value! # wait for async operation to complete

      increment =  DatadogApi.increment('counter')
      expect(increment).to be_a Concurrent::Future
      increment.value! # wait for async operation to complete

      expect(Dogapi::Client).to have_received(:new).once
      expect(@mock_dogapi).to have_received(:emit_point).once.with('test.dogapi.volume', 11, {:tags => ["env:"+Rails.env], :type => "gauge"})
      expect(@mock_dogapi).to have_received(:emit_point).once.with('test.dogapi.counter', 1, {:tags => ["env:"+Rails.env], :type => "count"})
    end

    context "if the emit_point call fails for a network error" do
      before do
        allow(@mock_dogapi).to receive(:emit_point).and_raise(Net::OpenTimeout)
      end

      it "does not raise any exceptions" do
        increment =  DatadogApi.increment('counter')
        expect(increment).to be_a Concurrent::Future
        increment.value! # wait for async operation to complete
      end
    end

    context "if the emit_point call fails for an unknown error" do
      before do
        allow(@mock_dogapi).to receive(:emit_point).and_raise(StandardError)
      end

      it "still raises the exception" do
        increment =  DatadogApi.increment('counter')
        expect(increment).to be_a Concurrent::Future
        expect { increment.value! }.to raise_error(StandardError)
      end
    end
  end

  context "when disabled" do
    before do
      DatadogApi.configure do |c|
        allow(c).to receive(:enabled).and_return(false)
      end
    end

    it 'does not initialize and call Dogapi::Client' do
      gauge = DatadogApi.gauge('volume', 11)
      expect(gauge).to be nil

      increment = DatadogApi.increment('counter')
      expect(increment).to be nil

      expect(Dogapi::Client).not_to have_received(:new)
      expect(@mock_dogapi).not_to have_received(:emit_point)
    end
  end
end
