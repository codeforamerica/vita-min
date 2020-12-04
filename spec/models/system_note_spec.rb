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
    let(:intake) { create :intake, :with_contact_info, primary_first_name: "Original first name" }

    context "with changes to the client profile" do
      before do
        intake.assign_attributes(primary_first_name: "New first name")
      end

      it "creates a new system note for each change" do
        expect {
          SystemNote.create_client_change_note(user, intake)
        }.to change(SystemNote, :count).by 1

        note = SystemNote.last

        expect(note.client).to eq intake.client
        expect(note.user).to eq user
        expect(note.body).to eq("#{user.name} changed #{changed_field} from Original first name to New first name at #{DateTime.now.strftime("%l:%M %p #{DateTime.now.zone}").strip}")
      end
    end
  end
end
