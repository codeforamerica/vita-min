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

describe SystemNote::OrganizationChange do
  let(:initiating_user) { create :user, name: "Marlie Mango" }
  let(:oregano_org) { create :vita_partner, name: "Oregano Org" }
  context 'when a change was not persisted to clients vita partner' do
    let(:client) { create :client }
    it "returns nil" do
      expect(described_class.generate!(client: client)).to be_nil
    end
  end

  context "with a recent change to vita partner id on a client" do
    context "when changing from nil -> having a vita partner" do
      let(:client) { create :client, vita_partner: nil }
      before do
        client.update(vita_partner: oregano_org)
      end

      context "with an initiating user" do
        it "has the correct message" do
          expect {
            described_class.generate!(client: client, initiated_by: initiating_user)
          }.to change(SystemNote::OrganizationChange, :count).by(1)
          note = SystemNote.last
          expect(note.body).to eq "Marlie Mango assigned client to Oregano Org."
          expect(note.user).to eq initiating_user
          expect(note.client).to eq client
        end
      end

      context "without an initiating user" do
        it "has the correct message" do
          expect {
            described_class.generate!(client: client)
          }.to change(SystemNote::OrganizationChange, :count).by(1)
          note = SystemNote.last
          expect(note.body).to eq "A system action assigned client to Oregano Org."
          expect(note.user).to eq nil
          expect(note.client).to eq client
        end
      end
    end

    context "when removing vita partner assignment" do
      let(:client) { create :client, vita_partner: oregano_org }
      before do
        client.update(vita_partner: nil)
      end

      context "with an initiating user" do
        it "has the correct message" do
          expect {
            described_class.generate!(client: client, initiated_by: initiating_user)
          }.to change(SystemNote::OrganizationChange, :count).by(1)
          note = SystemNote.last
          expect(note.body).to eq "Marlie Mango removed partner assignment from client. (Previously assigned to Oregano Org.)"
          expect(note.user).to eq initiating_user
          expect(note.client).to eq client
        end
      end

      context "without an initiating user" do
        it "has the correct message" do
          expect {
            described_class.generate!(client: client)
          }.to change(SystemNote::OrganizationChange, :count).by(1)
          note = SystemNote.last
          expect(note.body).to eq "A system action removed partner assignment from client. (Previously assigned to Oregano Org.)"
          expect(note.user).to eq nil
          expect(note.client).to eq client
        end
      end
    end

    context "when changing vita partner assignment" do
      let(:client) { create :client, vita_partner: oregano_org }
      before do
        client.update(vita_partner: (create :vita_partner, name: "Koala Kitchen"))
      end

      context "with an initiating user" do
        it "has the correct message" do
          expect {
            described_class.generate!(client: client, initiated_by: initiating_user)
          }.to change(SystemNote::OrganizationChange, :count).by(1)
          note = SystemNote.last
          expect(note.body).to eq "Marlie Mango changed assigned partner from Oregano Org to Koala Kitchen."
          expect(note.user).to eq initiating_user
          expect(note.client).to eq client
        end
      end

      context "without an initiating user" do
        it "has the correct message" do
          expect {
            described_class.generate!(client: client)
          }.to change(SystemNote::OrganizationChange, :count).by(1)
          note = SystemNote.last
          expect(note.body).to eq "A system action changed assigned partner from Oregano Org to Koala Kitchen."
          expect(note.user).to eq nil
          expect(note.client).to eq client
        end
      end
    end
  end
end
