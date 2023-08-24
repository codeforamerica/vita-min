require 'rails_helper'

RSpec.describe Hub::Admin::ExperimentsController do
  describe "#index" do
    context "as an admin" do
      let(:user) { create(:admin_user) }
      let(:experiment) { create(:experiment) }
      let(:organization) { create(:organization) }
      before do
        sign_in user
      end

      context "when showing all experiments" do
        it "shows no experiment participant information" do
          get :index
          expect(assigns[:experiment_participants]).to be_nil
        end
      end
    end
  end

  describe "#show" do
    context "as an admin" do
      let(:user) { create(:admin_user) }
      let(:experiment) { create(:experiment) }
      let!(:experiment_participant) { create(:experiment_participant, experiment: experiment, record: create(:intake))}

      before do
        sign_in user
      end

      it "shows experiment participant information" do
        get :show, params: {id: experiment.id}
        expect(assigns[:experiment_participants]).to eq([experiment_participant])
      end
    end
  end

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
