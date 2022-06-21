require "rails_helper"

describe TextExperiment do
  context "when cannot find a client" do
    before do
      allow(CSV).to receive(:read).and_return ([["client_id"], ["12312343124"]])
    end
    it "does not raise an error" do
      expect {
        TextExperiment.run
      }.not_to raise_error
    end
  end

  context "when it can find a client" do
    let(:client) { create :client }
    let!(:archived_intake) { create :archived_2021_ctc_intake, primary_first_name: "Samantha", client: client }
    before do
      allow(CSV).to receive(:read).and_return ([["client_id"], [client.id]])
      allow(ClientMessagingService).to receive(:send_text_message)
    end

    it "sends the messages to that client" do
      TextExperiment.run
      TextExperiment.treatments.each do |treatment|
        expect(ClientMessagingService).to have_received(:send_text_message).with(
          client: client,
          user: nil,
          body: treatment[:message] % { name: "Samantha" }
        )
      end
    end
  end
end