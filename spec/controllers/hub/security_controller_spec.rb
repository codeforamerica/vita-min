require 'rails_helper'

RSpec.describe Hub::SecurityController do
  context "when there is no current intake" do
    let(:client) { create :client, intake: intake }
    let(:intake) { build(:intake, preferred_name: "Ivan Intake") }

    render_views

    before do
      sign_in create(:admin_user)
    end

    it "shows security information" do
      get :show, params: { id: client.id }
      expect(response.body).to include(intake.preferred_name)
    end

    context "for an archived intake" do
      let(:intake) { nil }
      let!(:archived_intake) { create :archived_2021_ctc_intake, client: client, preferred_name: "Andy Archive" }

      it "shows security information" do
        get :show, params: { id: client.id }
        expect(response.body).to include(archived_intake.preferred_name)
      end
    end
  end
end
