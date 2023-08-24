describe Middleware::RejectBadlyEncodedHeaders do
  let(:mock_app) { double }
  subject { described_class.new(mock_app) }

  before do
    allow(mock_app).to receive(:call)
  end

  describe "#call" do
    context "with a valid referer" do
      let(:env) { {"HTTP_REFERER" => "https://example.com", "rack.input" => double} }

      it "calls into the app" do
        subject.call(env)
        expect(mock_app).to have_received(:call).with(env)
      end
    end

    context "with invalid UTF-8 in the HTTP_REFERER" do
      it "returns HTTP 400 Bad Request" do
        result = subject.call({"HTTP_REFERER" => "\xc3", "rack.input" => double})
        expect(mock_app).not_to have_received(:call)
        expect(result[0]).to eq(400)
      end
    end

    context "with no referer" do
      let(:env) { {"rack.input" => double} }

      it "calls into the app" do
        subject.call(env)
        expect(mock_app).to have_received(:call).with(env)
      end
    end
  end
end
