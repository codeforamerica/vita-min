# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  document_type     :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  intake_id         :bigint
#  zendesk_ticket_id :bigint
#
# Indexes
#
#  index_documents_on_intake_id  (intake_id)
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
end
