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
