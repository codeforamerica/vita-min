require 'rails_helper'

RSpec.describe Hub::BulkActions::BaseBulkActionsController do
  let(:intake) { build :intake, :with_contact_info }
  let(:client) { create :client, vita_partner: organization, intake: intake }
  let(:tax_return_1) { create :tax_return, client: client }
  let(:tax_return_2) { create :tax_return, client: client, year: 2019 }
  let(:tax_return_selection) { create :tax_return_selection, tax_returns: [tax_return_1, tax_return_2] }
  let(:organization) { create :organization }
  let(:user) { create :organization_lead_user, organization: organization }

  controller do
    def edit
      head :ok
    end
  end

  before do
    routes.draw do
      namespace :hub do
        namespace :bulk_actions do
          get "/:tax_return_selection_id/edit" => "base_bulk_actions#edit"
        end
      end
    end
  end

  describe "#edit" do
    let(:params) { { tax_return_selection_id: tax_return_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in user }

      context "before_actions" do
        let(:bulk_action_form) { instance_double(Hub::BulkActionForm) }

        before do
          allow(Hub::BulkActionForm).to receive(:new).and_return(bulk_action_form)
        end

        it "loads the form" do
          get :edit, params: params

          expect(Hub::BulkActionForm).to have_received(:new).with(tax_return_selection)
          expect(assigns(:form)).to eq(bulk_action_form)
        end

        context "when the user cannot access all the selected clients" do
          let(:inaccessible_org) { create :organization }
          let(:intake1) { create(:intake, :with_contact_info) }
          let(:intake2) { create(:intake, :with_contact_info) }
          let(:accessible_tax_return) { create(:gyr_tax_return, :intake_in_progress, tax_return_selections: [tax_return_selection]) }
          let(:inaccessible_tax_return) { create(:gyr_tax_return, :intake_in_progress, tax_return_selections: [tax_return_selection]) }
          let!(:accessible_client) { create :client, intake: intake1, tax_returns: [accessible_tax_return], vita_partner: organization }
          let!(:inaccessible_client) { create :client, intake: intake2, tax_returns: [inaccessible_tax_return], vita_partner: inaccessible_org }

          it "returns a 403" do
            get :edit, params: params
            expect(response).to be_forbidden
          end
        end

        context "with only clients who don't have sufficient contact info" do
          let(:intake) { build :intake, email_notification_opt_in: "yes", email_address: nil, sms_notification_opt_in: "yes", sms_phone_number: nil }

          it "shows a message to the user with number of clients who have no contact info for their preferences" do
            get :edit, params: params

            expect(assigns(:no_contact_info_count)).to eq(1)
          end

          it "excludes them from locale_counts" do
            get :edit, params: params

            expect(assigns(:locale_counts).values.sum).to eq(0)
          end
        end
      end
    end
  end
end
