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
require 'rails_helper'

describe SystemNote::StatusChange do
  describe ".generate!" do
    let(:user) { create :user, name: "Olive Oil" }
    let(:tax_return) { create :tax_return, :intake_in_progress, year: 3020 }

    context "with recently persisted changes and provided user" do
      before do
        tax_return.transition_to(:intake_ready)
      end

      it "can track the changes" do
        expect {
          SystemNote::StatusChange.generate!(initiated_by: user, tax_return: tax_return)
        }.to change(SystemNote, :count).by 1

        note = SystemNote.last

        expect(note.user).to eq(user)
        expect(note.client).to eq(tax_return.client)
        expect(note.body).to eq("#{user.name_with_role} updated 3020 tax return status from Intake/Not ready to Intake/Ready for review")
      end
    end

    context "with explicitly passed old/new status" do
      let(:tax_return) { create :tax_return, client: (create :client), year: 3020 }

      it "SystemNote::StatusChange.generate! with old/new status params, without user" do
        expect {
          SystemNote::StatusChange.generate!(tax_return: tax_return, old_status: "intake_in_progress", new_status: :file_ready_to_file)
        }.to change {SystemNote.count}.by(1)

        system_note = SystemNote.last
        expect(system_note.body).to eq "Automated update of #{tax_return.year} tax return status from Intake/Not ready to Final steps/Ready to file"
        expect(system_note.client_id).to eq tax_return.client_id
      end

      it "raises an exception if the system note fails to save" do
        tax_return.client = nil

        expect {
          SystemNote::StatusChange.generate!(tax_return: tax_return, old_status: "intake_in_progress", new_status: :file_ready_to_file)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "without a user" do
      before do
        tax_return.transition_to :intake_ready
      end

      it "can track the changes" do
        expect {
          SystemNote::StatusChange.generate!(tax_return: tax_return)
        }.to change(SystemNote, :count).by 1

        note = SystemNote.last

        expect(note.user).to eq(nil)
        expect(note.client).to eq(tax_return.client)
        expect(note.body).to include("Automated update")
      end
    end
  end
end
