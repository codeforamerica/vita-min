require 'rails_helper'

require_relative '../../lib/middleware/cleanup_request_host_headers'

describe Middleware::CleanupRequestHostHeaders do
  let(:mock_app) { double }
  subject { described_class.new(mock_app) }

  before do
    allow(mock_app).to receive(:call)
  end

  describe "#call" do
    it "allows most headers but filters HTTP_X_FORWARDED_HOST" do
      subject.call({"HTTP_HOST" => "example.com", "HTTP_X_FORWARDED_HOST" => "www2.example.com"})
      expect(mock_app).to have_received(:call).with({"HTTP_HOST" => "example.com"})
    end

    it ""
  end
end
