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

RSpec.describe SystemNote do
  describe ".create_system_status_change_note!" do
    let(:tax_return) { create :tax_return, client: (create :client), year: 3020 }

    before do
      tax_return.status = :file_ready_to_file
    end

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

  describe "SystemNote::StatusChange.generate! with user, with inferred old/new status params" do
    let(:user) { create :user, name: "Olive Oil" }
    let(:tax_return) { create :tax_return, status: "intake_in_progress", year: 3020 }

    context "with recently persisted changes" do
      before do
        tax_return.update(status: "intake_ready")
      end
      it "can track the changes" do
        expect {
          SystemNote::StatusChange.generate!(initiated_by: user, tax_return: tax_return)
        }.to change(SystemNote, :count).by 1

        note = SystemNote.last

        expect(note.user).to eq(user)
        expect(note.client).to eq(tax_return.client)
        expect(note.body).to eq("Olive Oil updated 3020 tax return status from Intake/Not ready to Intake/Ready for review")
      end
    end
  end

  describe "#create_client_change_note" do
    let(:user) { create :user }
    let(:intake) { create :intake, :with_contact_info, primary_first_name: "Original first name", primary_last_name: "Original last name" }

    context "with changes to the client profile" do
      before do
        intake.update(primary_first_name: "New first name", primary_last_name: "New last name", primary_last_four_ssn: "2345", spouse_last_four_ssn: "1234")
      end

      it "creates a system note summarizing all changes" do
        expect {
          SystemNote::ClientChange.generate!(initiated_by: user, intake: intake)
        }.to change(SystemNote, :count).by 1

        note = SystemNote.last

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
          SystemNote::ClientChange.generate!(initiated_by: user, intake: Intake.find(intake.id))
        }.not_to change(SystemNote, :count)
      end
    end

    context "when updated_at is the only thing that changes" do
      it "creates no system note" do
        intake.update(updated_at: Time.now)

        expect {
          SystemNote::ClientChange.generate!(initiated_by: user, intake: intake)
        }.not_to change(SystemNote, :count)
      end
    end
  end

  describe "SystemNote::AssignmentChange.generate!" do
    let(:intake) { create :intake, :with_contact_info }
    let(:tax_return) { create :tax_return, client: Client.new(intake: intake), year: 2019 }
    let(:current_user) { create :user, name: "Example User" }
    let(:user_to_assign) { create :user, name: "Alice" }

    context "with a recent change to tax return assignment" do
      before do
        tax_return.update(assigned_user: user_to_assign)
      end

      it "creates a system note" do
        expect {
          SystemNote::AssignmentChange.generate!(initiated_by: current_user, tax_return: tax_return)
        }.to change(SystemNote, :count).by 1
      end

      it "describes the change" do
        SystemNote::AssignmentChange.generate!(initiated_by: current_user, tax_return: tax_return)
        expect(SystemNote.last.client).to eq(tax_return.client)
        expect(SystemNote.last.body).to eq("Example User assigned 2019 return to Alice.")
      end
    end

    context "when the tax return assignment is updated to the same user as before" do
      let(:user) { create :admin_user }
      let(:tax_return) { create :tax_return, assigned_user: user, year: 2019 }
      before do
        tax_return.update(assigned_user: user)
      end

      it "does not create a note" do
        expect(SystemNote::AssignmentChange.generate!(initiated_by: current_user, tax_return: tax_return)).to be_nil
      end
    end

    context "when the tax return assignment changes to nil" do
      let(:user) { create :admin_user }
      let(:tax_return) { create :tax_return, assigned_user: user, year: 2019 }
      before do
        tax_return.update(assigned_user: nil)
      end

      it "creates a note indicating it was unassigned" do
        expect {
          SystemNote::AssignmentChange.generate!(initiated_by: current_user, tax_return: tax_return)
        } .to change(SystemNote, :count).by 1
        expect(SystemNote.last.body).to eq "Example User removed assignment from 2019 return."
      end
    end
  end
end
