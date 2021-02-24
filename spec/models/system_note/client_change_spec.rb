# == Schema Information
#
# Table name: system_notes
#
#  id         :bigint           not null, primary key
#  body       :text
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
require 'rails_helper'

describe SystemNote::ClientChange do
  describe ".generate!" do
    let(:user) { create :user }
    let(:intake) { create :intake, :with_contact_info, primary_first_name: "Original first name", primary_last_name: "Original last name" }

    context "with changes to the client profile" do
      before do
        intake.update(primary_first_name: "New first name", primary_last_name: "New last name", primary_last_four_ssn: "2345", spouse_last_four_ssn: "1234")
      end

      it "creates a system note summarizing all changes" do
        expect {
          described_class.generate!(initiated_by: user, intake: intake)
        }.to change(described_class, :count).by 1

        note = described_class.last

        expect(note.client).to eq intake.client
        expect(note.user).to eq user
        expect(note.body).not_to include("encrypted spouse last four ssn")
        expect(note.body).not_to include("encrypted primary last four ssn")

        expect(note.body).to include("primary first name from Original first name to New first name")
        expect(note.body).to include("primary last name from Original last name to New last name")
      end
    end

    context "without any changes" do
      it "creates no system note" do
        expect {
          described_class.generate!(initiated_by: user, intake: Intake.find(intake.id))
        }.not_to change(SystemNote, :count)
      end
    end

    context "when updated_at is the only thing that changes" do
      it "creates no system note" do
        intake.update(updated_at: Time.now)

        expect {
          described_class.generate!(initiated_by: user, intake: intake)
        }.not_to change(described_class, :count)
      end
    end
  end
end
