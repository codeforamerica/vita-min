require 'rails_helper'

RSpec.describe Hub::SecurityController do
  context "when there is no current intake" do
    let(:client) { create :client }

    before do
      sign_in create(:admin_user)
    end

    it "shows no duplicate bank client ids" do
      get :show, params: { id: client.id }
      expect(assigns(:duplicate_bank_client_ids)).to eq([])
    end
  end
end
