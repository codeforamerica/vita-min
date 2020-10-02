# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  display_name         :string
#  document_type        :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :bigint
#  documents_request_id :bigint
#  intake_id            :bigint
#  zendesk_ticket_id    :bigint
#
# Indexes
#
#  index_documents_on_client_id             (client_id)
#  index_documents_on_documents_request_id  (documents_request_id)
#  index_documents_on_intake_id             (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (documents_request_id => documents_requests.id)
#

require "rails_helper"

describe Document do
  describe "validations" do
    let(:document) { build :document }

    it "requires essential fields" do
      document = Document.new

      expect(document).to_not be_valid
      expect(document.errors).to include :intake
      expect(document.errors).to include :document_type
    end

    describe "#document_type" do
      it "expects document_type to be a valid choice" do
        document.document_type = "Book Report"
        expect(document).not_to be_valid
        expect(document.errors).to include :document_type
      end
    end
  end

  describe "before_save" do
    context "when there is already a display name" do
      let(:document) { build :document, display_name: "HumanReadable.jpg" }

      it "keeps the given display name" do
        document.save

        expect(document.display_name).to eq "HumanReadable.jpg"
      end
    end

    context "when there is no display name and there is an attachment" do
      let(:document) { build :document, :with_upload, upload_path: Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png") }

      it "sets the default display name to the attachment filename" do
        document.save

        expect(document.display_name).to eq "test-pattern.png"
      end
    end

    context "when there is no display name and no attachment" do
      let(:document) { build :document }

      it "sets the default display name to Untitled" do
        document.save

        expect(document.display_name).to eq "Untitled"
      end
    end
  end
end
