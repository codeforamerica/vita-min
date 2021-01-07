# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  contact_record_type  :string
#  display_name         :string
#  document_type        :string           default("Other"), not null
#  uploaded_by_type     :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :bigint
#  contact_record_id    :bigint
#  documents_request_id :bigint
#  intake_id            :bigint
#  tax_return_id        :bigint
#  uploaded_by_id       :bigint
#  zendesk_ticket_id    :bigint
#
# Indexes
#
#  index_documents_on_client_id                                  (client_id)
#  index_documents_on_contact_record_type_and_contact_record_id  (contact_record_type,contact_record_id)
#  index_documents_on_documents_request_id                       (documents_request_id)
#  index_documents_on_intake_id                                  (intake_id)
#  index_documents_on_tax_return_id                              (tax_return_id)
#  index_documents_on_uploaded_by_type_and_uploaded_by_id        (uploaded_by_type,uploaded_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (documents_request_id => documents_requests.id)
#  fk_rails_...  (tax_return_id => tax_returns.id)
#

require "rails_helper"

describe Document do
  let(:attachment) { Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png") }
  describe "validations" do
    let(:document) { build :document }
    it "requires essential fields" do
      document = Document.new(document_type: nil)

      expect(document).to_not be_valid
      expect(document.errors).to include :document_type
      expect(document.errors).to include :upload
    end

    describe "#document_type" do
      it "expects document_type to be a valid choice" do
        document.document_type = "Book Report"
        expect(document).not_to be_valid
        expect(document.errors).to include :document_type
      end
    end

    describe "#tax_return_belongs_to_client" do
      let(:client){ create :client }
      let(:document) { build :document, client: client, tax_return: tax_return }

      context "with a tax return for a different client" do
        let(:tax_return) { create :tax_return }

        it "is not valid" do
          expect(document).not_to be_valid
          expect(document.errors).to include :tax_return
        end
      end

      context "with a tax return for the same client" do
        let(:tax_return) { create :tax_return, client: client }

        it "is valid" do
          expect(document).to be_valid
        end
      end

      context "with no tax return" do
        let(:tax_return) { nil }

        it "is valid" do
          expect(document).to be_valid
        end
      end
    end
  end

  describe "#document_type" do
    it "defaults to 'Other'" do
      expect(Document.new.document_type).to eq DocumentTypes::Other.key
    end
  end

  describe "before_save" do
    context "when created with a display_name and attachment" do
      let(:document) { build :document, display_name: "HumanReadable.jpg" }

      it "keeps the given display name" do
        document.save

        expect(document.display_name).to eq "HumanReadable.jpg"
      end
    end

    context "when there is no display name and there is an attachment" do
      let(:document) { build :document, upload_path: attachment }

      it "sets the default display name to the attachment filename" do
        document.save

        expect(document.display_name).to eq "test-pattern.png"
      end
    end
  end

  describe "creating a document" do
    let(:document) { build :document }
    let(:object) { document }

    context "when client is the uploader" do
      it_behaves_like "an incoming interaction" do
        let(:client) { create :client }
        let(:subject) { build :document, client: client, uploaded_by: client }
      end
    end

    context "when an explicit uploader is not set" do
      let(:document) { build :document }
      it "sets the uploaded_by to the client" do
        expect { document.save }.to change(document, :uploaded_by).from(nil).to(document.client)
      end

      it_behaves_like "an incoming interaction" do
        let(:subject) { build :document }
      end
    end
  end
end
