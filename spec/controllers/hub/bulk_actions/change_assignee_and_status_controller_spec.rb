require 'rails_helper'

RSpec.describe Hub::BulkActions::ChangeAssigneeAndStatusController do
  let(:client) { create :client, vita_partner: site, intake: build(:intake) }
  let(:site) { create :site }
  let(:organization) { create :organization }

  let!(:team_member) { create :user, role: create(:team_member_role, site: site) }
  let!(:site_coordinator) { create :user, role: create(:site_coordinator_role, site: site) }
  let!(:inaccessible_user) { create :user }

  let(:tax_return_1) { create :gyr_tax_return, :file_ready_to_file, assigned_user: team_member, client: client }
  let(:tax_return_2) { create :tax_return, :review_signature_requested, assigned_user: team_member, client: client, year: 2019 }
  let(:tax_return_3) { create :tax_return, :review_signature_requested, assigned_user: site_coordinator, client: client, year: 2018 }
  let(:unselected_tax_return) { create :gyr_tax_return, :file_efiled, assigned_user: team_member }
  let!(:tax_return_selection) { create :tax_return_selection, tax_returns: [tax_return_1, tax_return_2, tax_return_3] }

  describe "#edit" do
    let(:params) { { tax_return_selection_id: tax_return_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in team_member }

      it "tr_statuses only includes current statuses of selected tax returns" do
        get :edit, params: params

        expect(assigns(:current_tr_statuses)).to match_array ["file_ready_to_file", "review_signature_requested"]
        expect(assigns(:current_tr_statuses)).not_to include unselected_tax_return.current_state
      end

      it "assignable users only includes accessible users" do
        get :edit, params: params

        expect(assigns(:assignable_users)).to match_array [team_member, site_coordinator]
        expect(assigns(:assignable_users)).not_to include inaccessible_user
      end
    end

    context "an unauthorized user" do
      let(:unauthorized_team_member) { create :user, role: create(:team_member_role, site: create(:site)) }

      before do
        sign_in unauthorized_team_member
      end

      it "returns a 403" do
        get :edit, params: params

        expect(response).to be_forbidden
      end
    end
  end

  describe "#update" do
    let(:new_status) { "review_ready_for_call" }
    let(:new_assigned_user_id) { site_coordinator.id }
    let(:params) do
      {
        tax_return_selection_id: tax_return_selection.id,
        hub_bulk_action_form: {
          status: new_status,
          assigned_user_id: new_assigned_user_id.to_s
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      before { sign_in team_member }

      context "when a new status and assignee are selected" do
        it "creates a notification and enqueues a job to do the work" do
          expect do
            put :update, params: params
          end.to change { team_member.notifications.count }.by(1).and(
            have_enqueued_job(BulkActionJob).with(
              task: :change_assignee_and_status,
              user: team_member,
              tax_return_selection: tax_return_selection,
              form_params: params[:hub_bulk_action_form]
            )
          )
          expect(team_member.notifications.last.notifiable.task_type).to eq("change_assignee_and_status")
          expect(team_member.notifications.last.notifiable.tax_return_selection).to eq(tax_return_selection)
          expect(response).to redirect_to hub_user_notifications_path
        end
      end

      context "when 'Keep current assignee' and 'Keep current status' are selected" do
        let(:params) do
          {
            tax_return_selection_id: tax_return_selection.id,
            hub_bulk_action_form: {
              assigned_user_id: BulkTaxReturnUpdate::KEEP,
              status: BulkTaxReturnUpdate::KEEP
            }
          }
        end

        it "creates an invalid form" do
          put :update, params: params

          expect(assigns(:form).valid?).to eq false
        end
      end

      context "when new assignee is a non-assignable user" do
        let(:new_assigned_user_id) { create(:team_member_user, name: "The Unassignable User").id }

        it "does not persist the tax return, renders new and flashes an error" do
          expect do
            put :update, params: params
          end.not_to change { team_member.notifications.count }
          expect(response).to be_forbidden
        end
      end

      context "an unauthorized user" do
        let(:unauthorized_team_member) { create :user, role: create(:team_member_role, site: create(:site)) }

        before do
          sign_in unauthorized_team_member
        end

        it "is not allowed to update the record" do
          expect do
            put :update, params: params
          end.not_to have_enqueued_job(BulkActionJob)
        end
      end
    end
  end
end
