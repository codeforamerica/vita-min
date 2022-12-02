require 'rails_helper'

RSpec.describe Hub::BulkActions::ChangeOrganizationController do
  let(:organization) { create :organization }
  let(:tax_return_selection) { create :tax_return_selection }
  let(:user) { create :organization_lead_user, organization: organization }

  describe "#edit" do
    let(:params) { { tax_return_selection_id: tax_return_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in user }

      context "since most users can't assign to all vita partners" do
        let!(:site) { create :site, parent_organization: organization }
        let!(:other_site) { create :site, parent_organization: organization }
        let!(:external_org) { create :organization }
        let!(:external_site) { create :site, parent_organization: external_org }

        it "only shows accessible vita partners in the dropdown" do
          get :edit, params: params

          expect(assigns(:vita_partners)).to match_array [organization, site, other_site]
        end
      end
    end
  end

  describe "#update" do
    let(:new_vita_partner) { create :site, parent_organization: organization }
    let(:params) do
      {
        tax_return_selection_id: tax_return_selection.id,
        hub_bulk_action_form: {
          vita_partner_id: new_vita_partner.id.to_s
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      before { sign_in user }

      context "with valid params" do
        let!(:selected_client) { create :client, intake: (create :intake), vita_partner: organization, tax_returns: [(create :gyr_tax_return, tax_return_selections: [tax_return_selection])] }

        it "creates a notification and enqueues a job to do the rest" do
          expect do
            put :update, params: params
          end.to change { user.notifications.count }.by(1).and(
            have_enqueued_job(BulkActionJob).with(
              task: :change_organization,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params[:hub_bulk_action_form]
            )
          )
          expect(user.notifications.last.notifiable.task_type).to eq("change_organization")
          expect(user.notifications.last.notifiable.tax_return_selection).to eq(tax_return_selection)
          expect(response).to redirect_to hub_user_notifications_path
        end
      end

      context "with invalid message params" do
        before do
          allow_any_instance_of(Hub::BulkActionForm).to receive(:valid?).and_return false
        end

        it "does not enqueue a job" do
          expect {
            expect {
              put :update, params: params
            }.not_to change { user.notifications.count }
          }.not_to have_enqueued_job
        end
      end
    end
  end
end
