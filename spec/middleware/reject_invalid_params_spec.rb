describe Middleware::RejectInvalidParams do
  let(:mock_app) { double }
  subject { described_class.new(mock_app) }

  before do
    allow(mock_app).to receive(:call)
  end

  describe "#call" do
    context "with regular valid params" do
      let(:env) { {"QUERY_STRING"=>"", "rack.input" => double} }

      it "calls into the app" do
        subject.call(env)
        expect(mock_app).to have_received(:call).with(env)
      end
    end

    context "with invalid UTF-8 in the query string" do
      it "returns HTTP 400 Bad Request" do
        result = subject.call({"QUERY_STRING"=>"\xc3", "rack.input" => double})
        expect(mock_app).not_to have_received(:call)
        expect(result[0]).to eq(400)
      end
    end
  end
end
