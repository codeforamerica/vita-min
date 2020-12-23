# == Schema Information
#
# Table name: system_notes
#
#  id         :bigint           not null, primary key
#  body       :text
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
  describe "#create_status_change_note" do
    let(:user) { create :user, name: "Olive Oil" }
    let(:tax_return) { create :tax_return, client: (create :client), status: "intake_in_progress", year: 3020 }

    context "with recently persisted changes" do
      before do
        tax_return.update(status: "intake_open")
      end
      it "can track the changes" do
        expect {
          SystemNote.create_status_change_note(user, tax_return)
        }.to change(SystemNote, :count).by 1

        note = SystemNote.last

        expect(note.user).to eq(user)
        expect(note.client).to eq(tax_return.client)
        expect(note.body).to eq("Olive Oil updated 3020 tax return status from Intake/In progress to Intake/Open")
      end
    end
  end

  describe "#create_client_change_note" do
    let(:user) { create :user }
    let(:intake) { create :intake, :with_contact_info, primary_first_name: "Original first name", primary_last_name: "Original last name" }

    context "with changes to the client profile" do
      before do
        intake.update(primary_first_name: "New first name", primary_last_name: "New last name")
      end

      it "creates a system note summarizing all changes" do
        expect {
          SystemNote.create_client_change_note(user, intake)
        }.to change(SystemNote, :count).by 1

        note = SystemNote.last

        expect(note.client).to eq intake.client
        expect(note.user).to eq user
        expect(note.body).to include("primary first name from Original first name to New first name")
        expect(note.body).to include("primary last name from Original last name to New last name")
      end
    end

    context "without any changes" do
      it "creates no system note" do
        expect {
          SystemNote.create_client_change_note(user, Intake.find(intake.id))
        }.not_to change(SystemNote, :count)
      end
    end

    context "when updated_at is the only thing that changes" do
      it "creates no system note" do
        intake.update(updated_at: Time.now)

        expect {
          SystemNote.create_client_change_note(user, intake)
        }.not_to change(SystemNote, :count)
      end
    end
  end

  describe "#create_assignment_change_note" do
    let(:intake) { create :intake, :with_contact_info }
    let(:tax_return) { create :tax_return, client: Client.new(intake: intake) }
    let(:current_user) { create :user, name: "Example User" }
    let(:user_to_assign) { create :user, name: "Alice" }

    context "with a recent change to tax return assignment" do
      before do
        tax_return.update(assigned_user: user_to_assign)
      end

      it "creates a system note" do
        expect {
          SystemNote.create_assignment_change_note(current_user, tax_return)
        }.to change(SystemNote, :count).by 1
      end

      it "describes the change" do
        SystemNote.create_assignment_change_note(current_user, tax_return)
        expect(SystemNote.last.client).to eq(tax_return.client)
        expect(SystemNote.last.body).to eq("Example User assigned 2019 return to Alice.")
      end
    end

    context "when the tax return is currently unassigned" do
      let(:tax_return) { create :tax_return, assigned_user: nil }
    end
  end
end
