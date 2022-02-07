describe Middleware::RespondWith400OnBadRequest do
  let(:mock_app) { double }
  subject { described_class.new(mock_app) }

  let(:success_response) { [200, {}, 'ok'] }
  let(:env) { { "rack.input" => StringIO.new("") } }
  let(:bad_request_message) { "Bad request" }
  let(:bad_request_response) { [
    400, {'Content-Type' => 'text/plain', 'Content-Length' => bad_request_message.size}, [bad_request_message]
  ] }

  before do
    allow(mock_app).to receive(:call).and_return(success_response)
  end

  describe "#call" do
    context "when app receives normal request parameters" do
      it "calls the app" do
        expect(subject.call(env)).to eq(success_response)
        expect(mock_app).to have_received(:call).with(env)
      end
    end

    context "when ActionDispatch::Request#params raises BadRequest" do
      let(:instance) { instance_double(ActionDispatch::Request) }

      before do
        allow(ActionDispatch::Request).to receive(:new).and_return(instance)
        allow(instance).to receive(:params).and_raise(ActionController::BadRequest)
      end

      it "returns a 400" do
        expect(subject.call(env)).to eq(bad_request_response)
        expect(mock_app).not_to have_received(:call)
      end
    end
  end
end
