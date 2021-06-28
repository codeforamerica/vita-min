describe Middleware::CleanupMimeTypeHeaders do
  let(:mock_app) { double }
  subject { described_class.new(mock_app) }

  before do
    allow(mock_app).to receive(:call)
  end

  describe "#clean_header!" do
    context "with a valid header" do
      it "passes the header through" do
        env = { 'HTTP_ACCEPT' => 'text/html' }
        subject.clean_header!(env, 'HTTP_ACCEPT')
        expect(env).to eq({ 'HTTP_ACCEPT' => 'text/html' })
      end
    end

    context "with a missing header" do
      it "leaves it unset" do
        env = { }
        subject.clean_header!(env, 'HTTP_ACCEPT')
        expect(env).to eq({ })
      end
    end

    context "with a blank header" do
      it "passes the header through" do
        env = { 'HTTP_ACCEPT' => '' }
        subject.clean_header!(env, 'HTTP_ACCEPT')
        expect(env).to eq({ 'HTTP_ACCEPT' => '' })
      end
    end

    context "when called with an invalid Accept header" do
      it "replaces it with unknown/unknown" do
        env ={ 'HTTP_ACCEPT' => 'invalid' }
        subject.clean_header!(env, 'HTTP_ACCEPT')
        expect(env).to eq({ 'HTTP_ACCEPT' => 'unknown/unknown' })
      end
    end
  end

  describe "#call" do
    before do
      allow(subject).to receive(:clean_header!)
    end

    it "cleans the Accept header and Content-Type headers" do
      subject.call({})
      expect(subject).to have_received(:clean_header!).with({}, 'HTTP_ACCEPT')
      expect(subject).to have_received(:clean_header!).with({}, 'CONTENT_TYPE')
    end
  end
end
