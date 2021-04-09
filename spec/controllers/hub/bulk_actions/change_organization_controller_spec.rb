require 'rails_helper'

RSpec.describe Hub::BulkActions::ChangeOrganizationController do
  let(:organization) { create :organization }
  let(:client_selection) { create :client_selection }
  let(:user) { create :organization_lead_user, organization: organization }

  describe "#edit" do
    let(:params) { { client_selection_id: client_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in user }

      it "should see change organization page" do
        get :edit, params: params

        expect(response).to be_ok
      end

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

      context "when the user cannot access all the selected clients" do
        render_views

        let(:inaccessible_org) { create :organization }
        let!(:accessible_client) { create :client_with_intake_and_return, client_selections: [client_selection], vita_partner: organization }
        let!(:inaccessible_client) { create :client_with_intake_and_return, client_selections: [client_selection], vita_partner: inaccessible_org }

        it "shows a warning and updates the message delivery counts" do
          get :edit, params: params

          expect(Nokogiri::HTML.parse(response.body)).to have_text "You’ve selected Change Organization for 2 clients"
          expect(response.body).to have_text "1 client will not be updated because you cannot access them."
          expect(response.body).to have_text "1 client prefers to receive their message in English."
        end
      end

      context "with clients that have different locales" do
        render_views

        context "with at least one client with locale: en" do
          before { client_selection.clients << create(:client, vita_partner: organization, intake: create(:intake, locale: "en")) }

          it "shows an english message input with a count" do
            get :edit, params: params

            expect(response.body).to have_text "1 client prefers to receive their message in English."
            message_input = Nokogiri::HTML.parse(response.body).at_css("#hub_bulk_action_form_message_body_en")
            expect(message_input).to be_present
          end
        end

        context "with at least one client with locale: es" do
          before { client_selection.clients << create(:client, vita_partner: organization, intake: create(:intake, locale: "es")) }

          it "shows an spanish message input with a count" do
            get :edit, params: params

            expect(response.body).to have_text "1 client prefers to receive their message in Spanish."
            message_input = Nokogiri::HTML.parse(response.body).at_css("#hub_bulk_action_form_message_body_es")
            expect(message_input).to be_present
          end
        end

        context "with at least one client with locale: nil" do
          before { client_selection.clients << create(:client, vita_partner: organization, intake: create(:intake, locale: nil)) }

          it "counts it as locale: en" do
            get :edit, params: params

            expect(response.body).to have_text "1 client prefers to receive their message in English."
            message_input = Nokogiri::HTML.parse(response.body).at_css("#hub_bulk_action_form_message_body_en")
            expect(message_input).to be_present
          end
        end
      end

      context "when the clients belong to various vita partners" do
        render_views

        let(:site_a) { create :site, parent_organization: organization, name: "Apple Alliance" }
        let(:site_b) { create :site, parent_organization: organization, name: "Banana Builders" }
        let(:site_c) { create :site, parent_organization: organization, name: "Carrot Communities" }

        before do
          create :client_with_intake_and_return, vita_partner: site_a, client_selections: [client_selection]
          create :client_with_intake_and_return, vita_partner: site_b, client_selections: [client_selection]
          create :client_with_intake_and_return, vita_partner: site_b, client_selections: [client_selection]
          create :client_with_intake_and_return, vita_partner: site_c, client_selections: [client_selection]
        end

        it "shows a list of the partners with an oxford comma" do
          get :edit, params: params

          expect(response.body).to have_text "You’ve selected Change Organization for 4 clients in the current organizations:"
          expect(response.body).to have_text "Apple Alliance, Banana Builders, and Carrot Communities"
        end
      end

      context "with clients who don't have sufficient contact info" do
        render_views

        before do
          client = create :client, vita_partner: organization, client_selections: [client_selection]
          create :intake, client: client, email_notification_opt_in: "yes", email_address: nil, sms_notification_opt_in: "yes", sms_phone_number: nil
        end

        it "shows a message to the user with number of clients who have no contact info for their preferences" do
          get :edit, params: params

          expect(response.body).to have_text "1 client does not have contact information and will not receive a message."
        end
      end
    end
  end

  describe "#update", active_job: true do
    let(:new_vita_partner) { create :site, parent_organization: organization }
    let(:params) do
      {
        client_selection_id: client_selection.id,
        hub_bulk_action_form: {
          vita_partner_id: new_vita_partner.id
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      before { sign_in user }

      context "updating organization" do
        let!(:selected_client) { create :client_with_intake_and_return, client_selections: [client_selection], vita_partner: organization }

        it "updates the organization on all selected clients and redirects to client selection page" do
          expect {
            put :update, params: params
          }.to change { selected_client.reload.vita_partner }.from(organization).to(new_vita_partner)

          # once notifications are in place, this should redirect to notifications instead
          expect(response).to redirect_to hub_client_selection_path(id: client_selection)
        end

        context "when user only has access to update some clients" do
          let!(:inaccessible_selected_client) { create :client_with_intake_and_return, client_selections: [client_selection], vita_partner: create(:organization) }

          it "only updates the clients that the user can access" do
            expect {
              put :update, params: params
            }.not_to change { inaccessible_selected_client.reload.vita_partner }
          end
        end

        context "when users are assigned to the returns and don't have access through the new partner" do
          let(:old_site) { create :site, parent_organization: organization }
          let(:assigned_user_at_old_site) { create :site_coordinator_user, site: old_site }
          let(:assigned_user_who_retains_access) { create :organization_lead_user, organization: organization }
          let(:selected_client) { create :client_with_intake_and_return, vita_partner: old_site, client_selections: [client_selection] }
          let!(:other_assigned_return) { create :tax_return, client: selected_client, assigned_user: assigned_user_who_retains_access, year: 2018 }
          let!(:unassigned_return) { create :tax_return, client: selected_client, year: 2017 }

          before do
            selected_client.tax_returns.first.update(assigned_user: assigned_user_at_old_site)
          end

          it "unassigns all users who are losing access" do
            put :update, params: params

            expect(assigned_user_at_old_site.reload.assigned_tax_returns).to be_empty
            expect(assigned_user_who_retains_access.reload.assigned_tax_returns).to eq [other_assigned_return]
          end
        end
      end

      context "sending messages" do
        context "with valid message params" do
          let(:english_message_body) { "I moved your case to a new org!" }
          let(:spanish_message_body) { "¡Mové su caso a una organización nueva!" }
          let(:params) do
            {
              client_selection_id: client_selection.id,
              hub_bulk_action_form: {
                vita_partner_id: new_vita_partner.id,
                message_body_en: english_message_body,
                message_body_es: spanish_message_body
              }
            }
          end

          before do
            allow_any_instance_of(Hub::BulkActionForm).to receive(:valid?).and_return true
          end

          it "enqueues a BulkMessagingJob with the right arguments" do
            put :update, params: params

            expect(BulkClientMessagingJob).to have_been_enqueued.with(
              client_selection,
              user,
              en: english_message_body,
              es: spanish_message_body,
            )
          end
        end

        context "with invalid message params" do
          before do
            allow_any_instance_of(Hub::BulkActionForm).to receive(:valid?).and_return false
          end

          it "does not enqueue a job" do
            put :update, params: params

            expect(BulkClientMessagingJob).not_to have_been_enqueued
          end
        end
      end

      context "creating a note" do
        let!(:selected_client_1) { create :client_with_intake_and_return, client_selections: [client_selection], vita_partner: organization }
        let!(:selected_client_2) { create :client_with_intake_and_return, client_selections: [client_selection], vita_partner: organization }
        let(:note_body) { "An internal note with some text in it" }
        let(:params) do
          {
            client_selection_id: client_selection.id,
            hub_bulk_action_form: {
              vita_partner_id: new_vita_partner.id,
              note_body: note_body
            }
          }
        end

        it "saves a note and fires related after creation hooks" do
          expect {
            put :update, params: params
          }.to change(Note, :count).by(2).and(change { selected_client_1.reload.last_internal_or_outgoing_interaction_at })

          expect(selected_client_1.notes.first.body).to eq note_body
          expect(selected_client_1.notes.first.user).to eq user
          expect(selected_client_2.notes.first.body).to eq note_body
          expect(selected_client_2.notes.first.user).to eq user
        end
      end
    end
  end
end
