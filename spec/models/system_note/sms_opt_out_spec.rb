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

RSpec.describe SystemNote::SmsOptOut do
  describe ".generate!" do
    let(:intake) { create(:intake) }
    let(:client) { intake.client }

    it "adds a new note" do
      expect {
        described_class.generate!(client: client)
      }.to change(SystemNote, :count).by(1)

      note = SystemNote.last

      expect(note.client).to eql(client)
      expect(note.body).to eql('Client replied "STOP" to opt out of text messages')
    end
  end
end
