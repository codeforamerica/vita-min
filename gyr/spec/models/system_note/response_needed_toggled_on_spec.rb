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

describe SystemNote::ResponseNeededToggledOn do
  let(:client) { create :client }
  let(:user) { create :user, name: "Teague Toggleson" }

  describe ".generate!" do
    it "creates the appropriate system note" do
      note = described_class.generate!(client: client, initiated_by: user)

      expect(note).to be_persisted
      expect(note.client).to eq client
      expect(note.user).to eq user
      expect(note.body).to eq "#{user.name_with_role} indicated that this client needs a response."
    end
  end
end
