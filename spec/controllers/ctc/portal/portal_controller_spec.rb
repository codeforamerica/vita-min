require "rails_helper"

describe Ctc::Portal::PortalController do
  let(:intake) { create :ctc_intake, current_step: "/en/last/question" }
  let(:client) { create :client, intake: intake, tax_returns: [create(:tax_return, year: 2020)] }

  context '#home' do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :home

    context "when authenticated" do
      before do
        sign_in client, scope: :client
      end

      it "renders home layout" do
        get :home

        expect(response).to render_template "home"
      end

      context "when there is no efile_submission" do
        it "renders with intake_in_progress status and defined current_step" do
          get :home
          expect(assigns(:status)).to eq "intake_in_progress"
          expect(assigns(:current_step)).to eq "/en/last/question"
        end
      end

      context "when an efile submission exists" do
        before do
          client.tax_returns.first.update(efile_submissions: [ create(:efile_submission, :rejected)])
        end

        it "renders with the submission status and nil current step" do
          get :home
          expect(assigns(:status)).to eq "rejected"
          expect(assigns(:current_step)).to eq nil
        end
      end
    end
  end
end