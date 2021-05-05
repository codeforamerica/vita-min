require "rails_helper"

RSpec.describe LoginLinkInsertionService do
  describe ".insert_links" do
    let(:client) { create :client }
    let!(:intake) { create :intake, locale: "es", client: client }

    context "when there are matches" do
      let(:body) { "something <<Link.E-signature>>" }

      context "with an outgoing text message" do
        let(:contact_record) { build :outgoing_text_message, client: client, body: body }

        it "creates a text message access token and inserts the link" do
          result = LoginLinkInsertionService.insert_links(contact_record)

          expect(result).to eq "something http://test.host/es/portal/login"
        end
      end

      context "with an outgoing email" do
        let(:contact_record) { build :outgoing_email, client: client, body: body }

        it "creates an email access token and inserts the link" do
          result = LoginLinkInsertionService.insert_links(contact_record)

          expect(result).to eq "something http://test.host/es/portal/login"
        end
      end
    end

    context "with a range of matching strings" do
      let(:inputs) do
        [
          "<<link.e-signature>>",
          "<<\nlink.e-signature\t \t>>",
          "<< LINK.E-SIGNATURE >>"
        ]
      end

      it "replaces them all" do
        outputs = inputs.map do |s|
          LoginLinkInsertionService.insert_links(build(:outgoing_email, client: client, body: s))
        end

        expect(outputs.uniq).to eq ["http://test.host/es/portal/login"]
      end
    end

    context "when there are no matches" do
      let(:body) { "something" }
      let(:contact_record) { build :outgoing_email, client: client, body: body }

      it "does not make any tokens and outputs the exact same body" do
        result = LoginLinkInsertionService.insert_links(contact_record)

        expect(result).to eq body
      end
    end
  end
end
