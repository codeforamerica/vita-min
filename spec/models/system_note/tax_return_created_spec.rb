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
require "rails_helper"

describe SystemNote::TaxReturnCreated do
  describe ".generate!" do
    let(:tax_return) { create(:tax_return, year: 2018) }

    context "an admin" do
      let(:user) { create :admin_user, name: "Admin User" }

      it "creates the appropriate system note" do
        note = described_class.generate!(tax_return: tax_return, initiated_by: user)

        expect(note).to be_persisted
        expect(note.client).to eq tax_return.client
        expect(note.user).to eq user
        expect(note.body).to eq "Admin User (Admin) added a 2018 tax return."
      end
    end

    context "a team member" do
      let(:user) { create :team_member_user, name: "Team User", site: (create :site, name: "Some Site") }

      it "creates the appropriate system note" do
        note = described_class.generate!(tax_return: tax_return, initiated_by: user)

        expect(note).to be_persisted
        expect(note.client).to eq tax_return.client
        expect(note.user).to eq user
        expect(note.body).to eq "Team User (Team Member - Some Site) added a 2018 tax return."
      end
    end

    context "A coalition lead" do
      let(:user) { create :coalition_lead_user, name: "Coal Ition", coalition: (create :coalition, name: "Some Coalition") }

      it "creates the appropriate system note" do
        note = described_class.generate!(tax_return: tax_return, initiated_by: user)

        expect(note).to be_persisted
        expect(note.client).to eq tax_return.client
        expect(note.user).to eq user
        expect(note.body).to eq "Coal Ition (Coalition Lead - Some Coalition) added a 2018 tax return."
      end
    end
  end
end