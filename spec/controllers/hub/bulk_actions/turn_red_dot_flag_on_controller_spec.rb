require 'rails_helper'

RSpec.describe Hub::BulkActions::TurnRedDotFlagOnController do
  let(:organization) { create :organization }
  let(:intake) { create :intake, client: create(:client, vita_partner: organization), product_year: Rails.configuration.product_year }
  let(:tax_return_1) { create :tax_return, client: intake.client, year: 2020 }
  let!(:tax_return_selection) { create :tax_return_selection, tax_returns: [tax_return_1] }
  let(:user) { create :organization_lead_user, organization: organization }

  describe "#edit" do
    let(:params) { { tax_return_selection_id: tax_return_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in user }

      it "renders ok" do
        get :edit, params: params

        expect(response).to be_ok
      end

      context "with an archived intake" do
        before do
          intake.update(product_year: Rails.configuration.product_year - 2)
        end

        it "response is forbidden (403)" do
          get :edit, params: params
          expect(response).to be_forbidden
        end
      end
    end
  end

  describe "#update" do
    let(:params) { { tax_return_selection_id: tax_return_selection.id } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      before { sign_in user }

      it "creates a notification and enqueues a job to turn on the red dot" do
        expect do
          put :update, params: params
        end.to change { user.notifications.count }.by(1).and(
          have_enqueued_job(BulkActionJob).with(
            task: :turn_red_dot_flag_on,
            user: user,
            tax_return_selection: tax_return_selection,
            form_params: {}
          )
        )
        expect(user.notifications.last.notifiable.task_type).to eq("turn_red_dot_flag_on")
        expect(user.notifications.last.notifiable.tax_return_selection).to eq(tax_return_selection)
        expect(response).to redirect_to hub_user_notifications_path
      end

      context "with an archived intake" do
        before do
          intake.update(product_year: Rails.configuration.product_year - 2)
        end

        it "response is forbidden (403)" do
          put :update, params: params
          expect(response).to be_forbidden
        end
      end
    end
  end
end