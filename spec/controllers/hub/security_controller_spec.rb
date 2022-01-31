require 'rails_helper'

RSpec.describe Hub::SecurityController do
  context "when there is no current intake" do
    let(:client) { intake.client }
    let(:intake) { create(:ctc_intake, preferred_name: "Ivan Intake") }
    let!(:bank_account) {  create(:bank_account, routing_number: "123456789", account_number: "87654321", intake: intake) }

    let(:other_client) { other_intake.client }
    let(:other_intake) { create(:ctc_intake, preferred_name: "Evan Entake") }
    let!(:other_bank_account) {  create(:bank_account, routing_number: "123456789", account_number: "87654321", intake: other_intake) }

    render_views

    before do
      sign_in create(:admin_user)
    end

    it "shows security information including IDs of other clients with the same bank account" do
      get :show, params: { id: client.id }
      expect(response.body).to include(intake.preferred_name)
      expect(assigns(:duplicate_bank_client_ids)).to eq([other_client.id])
    end

    context "for an archived intake" do
      let(:intake) { nil }
      let(:client) { build(:client) }
      let(:bank_account) { nil }

      let!(:archived_intake) { create :archived_2021_ctc_intake, client: client, preferred_name: "Andy Archive" }
      let!(:archived_bank_account) {  create(:archived_2021_bank_account, routing_number: "123456789", account_number: "87654321", intake: archived_intake) }

      let(:other_archived_client) { build(:client) }
      let!(:other_archived_intake) { create :archived_2021_ctc_intake, client: other_archived_client, preferred_name: "Aiden Archive" }
      let!(:other_archived_bank_account) {  create(:archived_2021_bank_account, routing_number: "123456789", account_number: "87654321", intake: other_archived_intake) }

      it "shows security information including IDs of archived clients with the same bank account" do
        get :show, params: { id: client.id }
        expect(response.body).to include(archived_intake.preferred_name)
        expect(assigns(:duplicate_bank_client_ids)).to eq([other_archived_client.id])
      end
    end
  end
end
