require 'rails_helper'

require_relative '../../lib/middleware/cleanup_request_host_headers'

describe Middleware::CleanupRequestHostHeaders do
  let(:mock_app) do
    Class.new do
      attr_reader :computed_host

      def call(env)
        @computed_host = Rack::Request.new(env).host
      end
    end.new
  end
  subject { described_class.new(mock_app) }

  before do
    allow(mock_app).to receive(:call).and_call_original
  end

  describe "#call" do
    it "filters HTTP_X_FORWARDED_HOST so request.host comes from the Host header" do
      subject.call({ "HTTP_HOST" => "example.com", "HTTP_X_FORWARDED_HOST" => "example.org" })
      expect(mock_app).to have_received(:call).with({ "HTTP_HOST" => "example.com" })
      expect(mock_app.computed_host).to eq("example.com")
    end
  end
end
