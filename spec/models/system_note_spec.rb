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
end
