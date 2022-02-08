require "rails_helper"

RSpec.describe Portal::PortalController, type: :controller do
  describe "#current_intake" do
    let(:session_intake) { create :intake }
    let(:client) { create :client, intake: (create :intake) }

    before do
      session[:intake_id] = session_intake.id
    end

    context "when the client is authenticated" do
      before do
        sign_in client, scope: :client
      end

      it "is the clients intake" do
        expect(subject.current_intake).to eq client.intake
      end
    end

    context "when the client is not authenticated" do
      it "is nil" do
        expect(subject.current_intake).to eq nil
      end
    end
  end

  describe "#home" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :home
    it_behaves_like :a_get_action_redirects_for_show_still_needs_help_clients, action: :home

    context "as an authenticated client" do
      before do
        sign_in client
      end

      context "with onboarding still to do" do
        let(:client) { create :client, intake: (create :intake, current_step: "/en/questions/additional-info") }

        before do
          create :tax_return, :intake_in_progress, year: 2018, client: client
          create :tax_return, :intake_in_progress, year: 2019, client: client
        end

        it "is ok" do
          get :home

          expect(response).to be_ok
        end

        it "exposes current_step and tax_returns are empty" do
          get :home

          expect(assigns(:current_step)).to eq "/en/questions/additional-info"
          expect(assigns(:tax_returns)).to eq []
        end
      end

      context "post-onboarding" do
        let(:client) { create :client, intake: (create :intake) }

        before do
          create :tax_return, :intake_in_progress, year: 2018, client: client
          create :tax_return, :prep_ready_for_prep, year: 2019, client: client
          create :tax_return, :intake_ready_for_call, year: 2021, client: client
        end

        it "is ok" do
          get :home

          expect(response).to be_ok
        end

        it "loads the client tax returns in desc order" do
          get :home

          expect(assigns(:tax_returns).map(&:year)).to eq [2021, 2019, 2018]
          expect(assigns(:current_step)).to eq nil
        end
      end
    end
  end
end
