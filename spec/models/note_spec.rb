# == Schema Information
#
# Table name: notes
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_notes_on_client_id  (client_id)
#  index_notes_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

describe Note do
  it_behaves_like "an internal interaction" do
    let(:subject) { build(:note) }
  end

  it "passes extra args to interaction tracking service" do
    allow(InteractionTrackingService).to receive(:record_internal_interaction)

    note = create(:note)

    expect(InteractionTrackingService).to have_received(:record_internal_interaction).with(
      note.client,
      user: note.user,
      interaction_type: "tagged_in_note",
      received_at: note.created_at,
    )
  end
end
