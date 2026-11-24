require "rails_helper"

describe Hub::PortalStatesController, type: :controller do
  describe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "as an admin" do
      render_views

      before { sign_in create(:admin_user) }

      [true, false].each do |flag_on|
        context "with client_portal_improvements #{flag_on ? 'on' : 'off'}" do
          before do
            flag_on ? Flipper.enable(:client_portal_improvements) : Flipper.disable(:client_portal_improvements)
          end

          after { Flipper.disable(:client_portal_improvements) }

          it "renders a card for every tax return state" do
            get :index

            expect(response).to be_ok
            expect(response.body).to include("State: intake_in_progress")
          end
        end
      end
    end
  end

  describe Hub::PortalStatesController::PseudoIntake do
    subject(:pseudo_intake) { described_class.new(current_step: "/documents") }

    it "answers what TaxReturnCardHelper asks of an intake" do
      expect(pseudo_intake.current_step).to eq "/documents"
      expect(pseudo_intake.pseudo?).to be true
      expect(pseudo_intake.client).to be_nil
    end
  end
end
