# == Schema Information
#
# Table name: system_notes
#
#  id         :bigint           not null, primary key
#  body       :text
#  data       :jsonb
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint
#
# Indexes
#
#  index_system_notes_on_client_id  (client_id)
#  index_system_notes_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

describe SystemNote::DocumentHelp do
  let(:client) { create :client }

  describe ".generate!" do
    context "with a valid help_type and doc_type" do
      it "creates a system note" do
        expect {
          described_class.generate!(client: client, help_type: :cant_locate, doc_type: DocumentTypes::Employment)
        }.to change(described_class, :count).by 1

        system_note = described_class.last
        expect(system_note.doc_type).to eq DocumentTypes::Employment
        expect(system_note.help_type).to eq "cant_locate"
      end
    end

    context "with an invalid help type" do
      it "raises an ArgumentError" do
        expect {
          described_class.generate!(client: client, help_type: "other", doc_type: DocumentTypes::Employment)
        }.to raise_error ArgumentError
      end
    end

    context "with an invalid doc type" do
      it "raises an ArgumentError" do
        expect {
          described_class.generate!(client: client, help_type: "cant_locate", doc_type: "Employment")
        }.to raise_error ArgumentError
      end
    end
  end

  describe "#doc_type" do
    let(:system_note) { described_class.generate!(client: client, doc_type: DocumentTypes::Employment, help_type: :doesnt_apply) }
    it "returns the document class for the stored document type" do
      expect(system_note.doc_type).to eq DocumentTypes::Employment
    end
  end

  describe "#help_type" do
    let(:system_note) { described_class.generate!(client: client, doc_type: DocumentTypes::Employment, help_type: :doesnt_apply) }
    it "returns the help type" do
      expect(system_note.help_type).to eq "doesnt_apply"
    end
  end
end
