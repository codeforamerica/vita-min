require 'rails_helper'

RSpec.describe Hub::Admin::ExperimentsController do
  describe "#update" do
    context "as an authenticated user" do
      let(:user) { create :admin_user }
      let(:experiment) { create :experiment }
      let(:enabled) { false }
      let(:vita_partners) { "" }
      let(:params) {
        {
          id: experiment.id,
          hub_admin_experiments_controller_experiment_form: {
            enabled: enabled,
            vita_partners: vita_partners
          }
        }
      }

      before do
        sign_in user
      end

      context "when there are no vita partners selected" do
        before do
          experiment.update(vita_partners: [create(:organization)])
        end

        it "clears associated vita partners" do
          put :update, params: params

          expect(experiment.reload.vita_partners).to be_empty
        end
      end

      context "when there are vita partners selected" do
        let(:vita_partner) { create :organization }
        let(:vita_partners) { JSON.generate([{ id: vita_partner.id, name: vita_partner.name, value: vita_partner.id }]) }

        it "saves associated vita partners" do
          put :update, params: params

          expect(experiment.vita_partners).to match_array([vita_partner])
        end
      end
    end
  end
end
