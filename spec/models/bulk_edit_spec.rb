# == Schema Information
#
# Table name: bulk_edits
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

describe BulkEdit do


  describe ".generate!" do
    context "with an unsupported record_type" do
      it "raises an error" do
        expect {
          described_class.generate!(record_type: User, user: create(:user))
        }.to raise_error(BulkEdit::UnsupportedRecordType)
      end
    end

    context "with all required fields" do
      let(:user) { create :user }
      it "creates a BulkEdit object and associated user notification" do
        expect {
          described_class.generate!(record_type: Client, user: user, successful_ids: [1, 2, 3], failed_ids: [3,4,5])
        }.to change(BulkEdit, :count).by(1)
         .and change(user.notifications, :count).by(1)

        expect(user.notifications.last.notifiable).to be_an_instance_of(BulkEdit)
      end
    end
  end

  context "reading data attributes" do
    let(:bulk_edit) { BulkEdit.generate!(record_type: Client, successful_ids: [1,2,3], failed_ids: [4,5,6], user: (create :user)) }

    describe "#successful_ids" do
      it "reads successful_ids from the data attribute" do
        expect(bulk_edit.successful_ids).to eq [1, 2, 3]
      end
    end

    describe "#failed_ids" do
      it "reads successful_ids from the data attribute" do
        expect(bulk_edit.failed_ids).to eq [4, 5, 6]
      end
    end

    describe "#record_type" do
      it "reads and constantizes from the data attribute" do
        expect(bulk_edit.record_type).to eq Client
      end
    end
  end

  describe "#records_path" do
    before do
      allow(subject).to receive(:id).and_return 100
    end

    context "only failed" do
      it "returns the client index path with query strings to indicate the bulk edit" do
        expect(subject.records_path(failed: true)).to eq "/en/hub/clients?bulk_edit=100&only=failed"
      end
    end

    context "only successful" do
      it "returns the client index path with query strings to indicate the bulk edit" do
        expect(subject.records_path(successful: true)).to eq "/en/hub/clients?bulk_edit=100&only=successful"
      end
    end

    context "all" do
      it "returns the client index path with query strings to indicate the bulk edit" do
        expect(subject.records_path).to eq "/en/hub/clients?bulk_edit=100"
      end
    end
  end
end
