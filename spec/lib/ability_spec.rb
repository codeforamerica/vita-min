require "rails_helper"

# TODO: .new is only needed if we are testing instance access instead of table access.
#   Consider removing .new in specs below unless necessary

describe Ability do
  let(:subject) { Ability.new(user) }

  context "as an admin" do
    let(:user) { create :admin_user, role: role }
    let(:role) { create :admin_role, state_file: false }

    it "can manage everything" do
      expect(subject.can?(:manage, Document.new)).to eq true
      expect(subject.can?(:manage, IncomingEmail.new)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new)).to eq true
      expect(subject.can?(:manage, Note.new)).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new)).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new)).to eq true
      expect(subject.can?(:manage, SystemNote.new)).to eq true
      expect(subject.can?(:manage, User.new)).to eq true
      expect(subject.can?(:manage, VitaPartner.new)).to eq true
    end

    it "cannot access flipper" do
      expect(subject.cannot?(:read, :flipper_dashboard)).to eq true
    end

    context "admin with @codeforamerica.org email" do
      let(:user) { create :admin_user, role: role, email: "someone@codeforamerica.org" }

      it "can manage flipper" do
        expect(subject.can?(:manage, :flipper_dashboard)).to eq true
      end
    end

    context "state_file true" do
      let(:role) { create :admin_role, state_file: true }

      it "can manage state file intakes" do
        expect(subject.can?(:manage, StateFileAzIntake.new)).to eq true
        expect(subject.can?(:manage, StateFileNyIntake.new)).to eq true
        expect(subject.can?(:manage, StateFile1099G.new)).to eq true
        expect(subject.can?(:manage, StateFileDependent.new)).to eq true
        expect(subject.can?(:manage, StateId.new)).to eq true
      end

      context "with a state efile submission" do
        let!(:state_efile_submission) { create :efile_submission, :for_state }

        it "can manage the state efile submission" do
          expect(subject.can?(:manage, state_efile_submission)).to eq true
        end
      end


      %w[state_file unfilled state_file_az state_file_ny state_file_md state_file_nc state_file_id].each do |service_type|
        context "with state efile error" do
          let!(:state_efile_error) { create :efile_error, service_type: service_type }
          it "can manage the state efile error" do
            expect(subject.can?(:manage, state_efile_error)).to eq true
          end
        end
      end

      context "with nj state efile error" do
        let!(:state_efile_error) { create :efile_error, service_type: "state_file_nj" }
        it "cannot manage the state efile error" do
          expect(subject.can?(:manage, state_efile_error)).to eq false
        end
      end
    end

    context "state_file false" do
      it "cannot manage state file intakes" do
        expect(subject.can?(:manage, StateFileAzIntake.new)).to eq false
        expect(subject.can?(:manage, StateFileNyIntake.new)).to eq false
        expect(subject.can?(:manage, StateFile1099G.new)).to eq false
        expect(subject.can?(:manage, StateFileDependent.new)).to eq false
        expect(subject.can?(:manage, StateId.new)).to eq false
      end

      context "with a state efile submission" do
        let!(:state_efile_submission) { create :efile_submission, :for_state }

        it "cannot read or manage the state efile submission" do
          expect(subject.can?(:read, state_efile_submission)).to eq false
          expect(subject.can?(:manage, state_efile_submission)).to eq false
        end
      end
    end

    context "with a client data unrelated to the user" do
      let(:client) { create(:client, vita_partner: create(:organization)) }

      it "can manage all" do
        expect(subject.can?(:manage, client)).to eq true
        expect(subject.can?(:destroy, client)).to eq true
        expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq true
        expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq true
        expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq true
        expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq true
        expect(subject.can?(:manage, Document.new(client: client))).to eq true
        expect(subject.can?(:manage, Note.new(client: client))).to eq true
      end
    end

    context "state_file_nj_staff" do
      let(:user) { create :state_file_nj_staff_user }
      let!(:state_efile_submission) { create :efile_submission, :for_state, data_source: create(:state_file_nj_intake) }
      let!(:state_efile_error) { create :efile_error, service_type: "state_file_nj" }
      let!(:faq_category) { create :faq_category, product_type: :state_file_nj }
      let!(:faq_item) { create(:faq_item, faq_category: faq_category) }

      it "can manage the state efile submission" do
        expect(subject.can?(:manage, state_efile_submission)).to eq true
        expect(subject.can?(:manage, state_efile_error)).to eq true
        expect(subject.can?(:manage, faq_category)).to eq true
        expect(subject.can?(:manage, faq_item)).to eq true
      end
    end
  end

  context "as a client_support role" do
    let(:client) { create :client, vita_partner: nil }
    let(:user) { create :client_success_user }
    it "can access a client when the vita_partner is nil" do
      expect(subject.can?(:manage, client)).to eq true
    end

    it "cannot do certain things to organizations or create some roles" do
      expect(subject.can?(:manage, Organization)).to eq false
      expect(subject.can?(:manage, SiteCoordinatorRole)).to eq false
      expect(subject.can?(:manage, AdminRole)).to eq false
      expect(subject.can?(:manage, ClientSuccessRole)).to eq false
      expect(subject.can?(:manage, GreeterRole)).to eq false
      expect(subject.can?(:manage, CoalitionLeadRole)).to eq false
      expect(subject.can?(:manage, OrganizationLeadRole)).to eq false
    end

    it "cannot manage state file intakes" do
      expect(subject.can?(:manage, StateFileAzIntake.new)).to eq false
      expect(subject.can?(:manage, StateFileNyIntake.new)).to eq false
      expect(subject.can?(:manage, StateFile1099G.new)).to eq false
      expect(subject.can?(:manage, StateFileDependent.new)).to eq false
      expect(subject.can?(:manage, StateId.new)).to eq false
    end
  end

  context "as a non-admin" do
    context "Permissions regarding Clients and their data" do
      shared_examples :cannot_manage_any_sites_or_orgs do
        it "cannot manage any VitaPartner records" do
          expect(subject.can?(:manage, VitaPartner)).to eq(false)
        end

        context "when the user can access a particular site" do
          let(:accessible_site) { create(:site) }
          let(:accessible_client) { create(:client, vita_partner: accessible_site) }
          before do
            allow(user).to receive(:accessible_vita_partners).and_return(VitaPartner.where(id: accessible_site))
          end

          it "cannot manage the site" do
            expect(subject.can?(:manage, accessible_site)).to eq false
          end
        end
      end

      shared_examples :can_only_read_accessible_org_or_site do
        let(:accessible_site) { create(:site) }
        before do
          allow(user).to receive(:accessible_vita_partners).and_return(Site.where(id: accessible_site))
        end

        it "can read the site" do
          expect(subject.can?(:read, accessible_site)).to eq true
        end

        it "cannot read a random site" do
          expect(subject.can?(:read, create(:site))).to eq false
        end
      end

      shared_examples :can_manage_but_not_delete_accessible_client do
        context "when the user can access a particular site" do
          let(:accessible_site) { create(:site) }
          let(:accessible_client) do
            create(
              :client,
              vita_partner: accessible_site,
              intake: build(
                :intake,
                :filled_out,
                preferred_name: "George Sr.",
                needs_help_2019: "yes",
                needs_help_2018: "yes",
                preferred_interview_language: "en", locale: "en",
                product_year: Rails.configuration.product_year
              ),
              tax_returns: [
                build(
                  :tax_return,
                  :intake_ready,
                  year: 2019,
                  service_type: "drop_off",
                  filing_status: nil
                ),
              ]
            )
          end

          before do
            allow(user).to receive(:accessible_vita_partners).and_return(VitaPartner.where(id: accessible_site))
          end

          it "can access all data for the client" do
            expect(subject.can?(:read, accessible_client)).to eq true
            expect(subject.can?(:update, accessible_client)).to eq true
            expect(subject.can?(:edit, accessible_client)).to eq true
            expect(subject.can?(:flag, accessible_client)).to eq true
            expect(subject.can?(:toggle_field, accessible_client)).to eq true
            expect(subject.can?(:edit_take_action, accessible_client)).to eq true
            expect(subject.can?(:update_take_action, accessible_client)).to eq true
            expect(subject.can?(:save_and_maybe_exit, accessible_client)).to eq true

            expect(subject.can?(:edit_13614c_form_page1, accessible_client)).to eq true
            expect(subject.can?(:edit_13614c_form_page2, accessible_client)).to eq true
            expect(subject.can?(:edit_13614c_form_page3, accessible_client)).to eq true
            expect(subject.can?(:edit_13614c_form_page4, accessible_client)).to eq true
            expect(subject.can?(:edit_13614c_form_page5, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page1, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page2, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page3, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page4, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page5, accessible_client)).to eq true
            expect(subject.can?(:cancel_13614c, accessible_client)).to eq true

            expect(subject.can?(:read, Document.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, Document.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, Document.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, Document.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, IncomingEmail.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, IncomingTextMessage.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, Note.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, Note.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, Note.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, Note.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, OutgoingEmail.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, OutgoingTextMessage.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, SystemNote.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, TaxReturn.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, TaxReturn.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, TaxReturn.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, TaxReturn.new(client: accessible_client))).to eq true

            expect(subject.can?(:manage, TaxReturnSelection.create!(tax_returns: [build(:gyr_tax_return, client: accessible_client)]))).to eq true
          end

          it "cannot delete a client" do
            expect(subject.can?(:destroy, accessible_client)).to eq false
          end
        end
      end

      shared_examples :can_manage_but_not_delete_accessible_client_when_assigned do
        context "when the user can access a particular site" do
          let(:accessible_site) { create(:site) }
          let(:accessible_client) do
            create(
              :client,
              vita_partner: accessible_site,
              intake: build(
                :intake,
                :filled_out,
                preferred_name: "George Sr.",
                needs_help_2019: "yes",
                needs_help_2018: "yes",
                preferred_interview_language: "en", locale: "en"
              ),
              tax_returns: [
                build(
                  :tax_return,
                  :intake_ready,
                  year: 2019,
                  service_type: "drop_off",
                  filing_status: nil,
                  assigned_user: user
                ),
              ]
            )
          end

          before do
            allow(user).to receive(:accessible_vita_partners).and_return(VitaPartner.where(id: accessible_site))
          end

          it "can access all data for the client" do
            expect(subject.can?(:read, accessible_client)).to eq true
            expect(subject.can?(:update, accessible_client)).to eq true
            expect(subject.can?(:edit, accessible_client)).to eq true
            expect(subject.can?(:flag, accessible_client)).to eq true
            expect(subject.can?(:toggle_field, accessible_client)).to eq true
            expect(subject.can?(:edit_take_action, accessible_client)).to eq true
            expect(subject.can?(:update_take_action, accessible_client)).to eq true
            expect(subject.can?(:unlock, accessible_client)).to eq false
            expect(subject.can?(:save_and_maybe_exit, accessible_client)).to eq true

            expect(subject.can?(:edit_13614c_form_page1, accessible_client)).to eq true
            expect(subject.can?(:edit_13614c_form_page2, accessible_client)).to eq true
            expect(subject.can?(:edit_13614c_form_page3, accessible_client)).to eq true
            expect(subject.can?(:edit_13614c_form_page4, accessible_client)).to eq true
            expect(subject.can?(:edit_13614c_form_page5, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page1, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page2, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page3, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page4, accessible_client)).to eq true
            expect(subject.can?(:update_13614c_form_page5, accessible_client)).to eq true
            expect(subject.can?(:cancel_13614c, accessible_client)).to eq true

            expect(subject.can?(:read, Document.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, Document.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, Document.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, Document.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, IncomingEmail.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, IncomingTextMessage.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, Note.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, Note.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, Note.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, Note.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, OutgoingEmail.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, OutgoingTextMessage.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, SystemNote.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, TaxReturn.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, TaxReturn.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, TaxReturn.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, TaxReturn.new(client: accessible_client))).to eq true

            expect(subject.can?(:manage, TaxReturnSelection.create!(tax_returns: [build(:gyr_tax_return, client: accessible_client)]))).to eq true
          end

          it "cannot delete a client" do
            expect(subject.can?(:destroy, accessible_client)).to eq false
          end
        end
      end

      shared_examples :cannot_manage_inaccessible_client do
        context "when the user cannot access a particular site" do
          let(:accessible_site) { create(:site) }
          let(:accessible_client) { create(:client, vita_partner: accessible_site) }
          let(:inaccessible_site) { create(:site) }
          let(:inaccessible_client) { create(:client, vita_partner: inaccessible_site) }
          before do
            allow(user).to receive(:accessible_vita_partners).and_return(VitaPartner.where(id: accessible_site))
          end

          it "can access no data for the client" do
            expect(subject.can?(:manage, inaccessible_client)).to eq false
            expect(subject.can?(:manage, Document.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, IncomingEmail.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, IncomingTextMessage.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, Note.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, OutgoingEmail.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, OutgoingTextMessage.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, SystemNote.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, TaxReturn.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, TaxReturnSelection.create!(tax_returns: [build(:gyr_tax_return, client: accessible_client), build(:gyr_tax_return, client: inaccessible_client)]))).to eq false
          end
        end
      end

      shared_examples :can_read_but_not_update_accessible_client_with_archived_intake do
        context "when the user can access a particular site" do
          let(:accessible_site) { create(:site) }
          let(:accessible_client) do
            create(
              :client,
              vita_partner: accessible_site,
              intake: build(
                :intake,
                :filled_out,
                preferred_name: "George Sr.",
                needs_help_2019: "yes",
                needs_help_2018: "yes",
                preferred_interview_language: "en", locale: "en",
                product_year: Rails.configuration.product_year - 2
              ),
              tax_returns: [
                build(
                  :tax_return,
                  :intake_ready,
                  year: 2019,
                  service_type: "drop_off",
                  filing_status: nil
                ),
              ]
            )
          end

          before do
            allow(user).to receive(:accessible_vita_partners).and_return(VitaPartner.where(id: accessible_site))
          end

          it "can access all data for the client" do
            expect(subject.can?(:read, accessible_client)).to eq true
            expect(subject.can?(:update, accessible_client)).to eq false
            expect(subject.can?(:edit, accessible_client)).to eq false

            expect(subject.can?(:flag, accessible_client)).to eq false
            expect(subject.can?(:toggle_field, accessible_client)).to eq false
            expect(subject.can?(:unlock, accessible_client)).to eq false

            expect(subject.can?(:edit_take_action, accessible_client)).to eq false
            expect(subject.can?(:update_take_action, accessible_client)).to eq false


            expect(subject.can?(:edit_13614c_form_page1, accessible_client)).to eq false
            expect(subject.can?(:edit_13614c_form_page2, accessible_client)).to eq false
            expect(subject.can?(:edit_13614c_form_page3, accessible_client)).to eq false
            expect(subject.can?(:edit_13614c_form_page4, accessible_client)).to eq false
            expect(subject.can?(:edit_13614c_form_page5, accessible_client)).to eq false
            expect(subject.can?(:update_13614c_form_page1, accessible_client)).to eq false
            expect(subject.can?(:update_13614c_form_page2, accessible_client)).to eq false
            expect(subject.can?(:update_13614c_form_page3, accessible_client)).to eq false
            expect(subject.can?(:update_13614c_form_page4, accessible_client)).to eq false
            expect(subject.can?(:update_13614c_form_page5, accessible_client)).to eq false
            expect(subject.can?(:save_and_maybe_exit, accessible_client)).to eq false
            expect(subject.can?(:cancel_13614c, accessible_client)).to eq false

            expect(subject.can?(:read, Document.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, Document.new(client: accessible_client))).to eq false
            expect(subject.can?(:update, Document.new(client: accessible_client))).to eq false
            expect(subject.can?(:destroy, Document.new(client: accessible_client))).to eq false

            expect(subject.can?(:read, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, IncomingEmail.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, IncomingTextMessage.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, Note.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, Note.new(client: accessible_client))).to eq false
            expect(subject.can?(:update, Note.new(client: accessible_client))).to eq false
            expect(subject.can?(:destroy, Note.new(client: accessible_client))).to eq false

            expect(subject.can?(:read, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, OutgoingEmail.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, OutgoingTextMessage.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:update, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:destroy, SystemNote.new(client: accessible_client))).to eq true

            expect(subject.can?(:read, TaxReturn.new(client: accessible_client))).to eq true
            expect(subject.can?(:create, TaxReturn.new(client: accessible_client))).to eq false
            expect(subject.can?(:update, TaxReturn.new(client: accessible_client))).to eq false
            expect(subject.can?(:destroy, TaxReturn.new(client: accessible_client))).to eq false

            expect(subject.can?(:manage, TaxReturnSelection.create!(tax_returns: [build(:gyr_tax_return, client: accessible_client)]))).to eq false
          end

          it "cannot delete a client" do
            expect(subject.can?(:destroy, accessible_client)).to eq false
          end
        end
      end

      context "users with valid non-admin roles" do
        context "a coalition lead" do
          let(:user) { create :coalition_lead_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
        end

        context "an organization lead" do
          let(:user) { create :organization_lead_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
        end

        context "a site coordinator" do
          let(:user) { create :site_coordinator_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
        end

        context "a team member" do
          let(:user) { create :team_member_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
          it_behaves_like :can_read_but_not_update_accessible_client_with_archived_intake
        end

        context "a greeter" do
          let(:user) { create :greeter_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client_when_assigned
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
        end
      end

      context "users in invalid states" do
        context "a nil user" do
          let(:user) { nil }
          let(:organization) { create :organization }
          let(:client) { create(:client, vita_partner: organization) }
          let(:intake) { create(:intake, vita_partner: organization, client: client) }

          it "cannot manage any client data" do
            expect(subject.can?(:manage, Client)).to eq false
            expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq false
            expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq false
            expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq false
            expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq false
            expect(subject.can?(:manage, User)).to eq false
            expect(subject.can?(:manage, Note.new(client: client))).to eq false
            expect(subject.can?(:manage, VitaPartner.new)).to eq false
            expect(subject.can?(:manage, SystemNote.new)).to eq false
          end
        end

        context "a user with a nil role" do
          let(:user) { build(:user, role_type: nil, role_id: nil) }
          let(:organization) { create :organization }
          let(:client) { create(:client, vita_partner: organization) }
          let(:intake) { create(:intake, vita_partner: organization, client: client) }

          it "cannot manage any client data" do
            expect(subject.can?(:manage, Client)).to eq false
            expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq false
            expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq false
            expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq false
            expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq false
            expect(subject.can?(:manage, User)).to eq false
            expect(subject.can?(:manage, Note.new(client: client))).to eq false
            expect(subject.can?(:manage, VitaPartner.new)).to eq false
            expect(subject.can?(:manage, SystemNote.new)).to eq false
          end
        end
      end
    end

    context "Permissions regarding Coalitions" do
      context "as a coalition lead" do
        let(:coalition) { create :coalition }
        let(:user) { create :coalition_lead_user, coalition: coalition }
        let(:inaccessible_coalition) { create :coalition }

        it "allows read access on your coalition" do
          expect(subject.can?(:read, Coalition)).to eq true
          expect(subject.can?(:read, coalition)).to eq true
        end

        it "does not allow read access on other coalitions" do
          expect(subject.can?(:read, inaccessible_coalition)).to eq false
        end
      end
    end

    context "Permissions regarding Users" do
      context "Managing users" do
        shared_examples :user_cannot_manage_other_users_in_their_site do
          let(:target_user) { create :site_coordinator_user }
          before do
            user.role.update(vita_partners: VitaPartner.where(id: target_user.role.sites))
          end

          it "cannot manage other users in a site they have access to" do
            expect(subject.can?(:manage, target_user)).to eq false
          end
        end

        shared_examples :user_can_manage_other_site_coordinators_and_team_members_in_their_site do
          let(:target_site_coordinator) { create :site_coordinator_user }
          let(:target_team_member) { create :team_member_user }
          before do
            sites = VitaPartner.where(id: target_site_coordinator.role.sites) + VitaPartner.where(id: target_team_member.role.sites)
            user.role.update(vita_partners: sites)
          end

          it "cannot manage other users in a site they have access to" do
            expect(subject.can?(:manage, target_site_coordinator)).to eq true
            expect(subject.can?(:manage, target_team_member)).to eq true
          end
        end

        shared_examples :user_can_manage_themselves do
          it "can manage themselves" do
            expect(subject.can?(:manage, user)).to eq true
          end
        end

        context "users with valid non-admin roles" do
          context "a coalition lead" do
            let(:user) { create :coalition_lead_user }

            it_behaves_like :user_can_manage_themselves

            context "users in their coalition" do
              let!(:target_user) do
                create :site_coordinator_user,
                       sites: [create(:site, parent_organization: create(:organization, coalition: user.role.coalition))]
              end

              it "can manage users in their coalition" do
                expect(subject.can?(:manage, target_user)).to eq true
              end
            end

            context "users outside their coalition" do
              let!(:target_user) { create :site_coordinator_user }

              it "cannot manage users outside their coalition" do
                expect(subject.can?(:manage, target_user)).to eq false
              end
            end
          end

          context "an organization lead" do
            let(:user) { create :organization_lead_user }

            it_behaves_like :user_can_manage_themselves

            context "users in their org" do
              let!(:target_user) do
                create :site_coordinator_user,
                       sites: [create(:site, parent_organization: user.role.organization)]
              end

              it "can manage users in their org" do
                expect(subject.can?(:manage, target_user)).to eq true
              end
            end

            context "users outside their org" do
              let!(:target_user) { create :site_coordinator_user }

              it "cannot manage users outside their org" do
                expect(subject.can?(:manage, target_user)).to eq false
              end
            end
          end

          context "a site coordinator" do
            let(:user) { create :site_coordinator_user }

            it_behaves_like :user_can_manage_themselves
            it_behaves_like :user_can_manage_other_site_coordinators_and_team_members_in_their_site
          end

          context "a team member" do
            let(:user) { create :team_member_user }

            it_behaves_like :user_can_manage_themselves
            it_behaves_like :user_cannot_manage_other_users_in_their_site
          end
        end
      end

      context "Viewing users" do
        let(:user) { create :team_member_user } # role is arbitrary in this test
        let(:other_user) { create :team_member_user }
        let(:inaccessible_user) { create :team_member_user }
        before do
          allow(user).to receive(:accessible_users).and_return([user, other_user])
        end

        it "allows read permission on all users returned by accessible_users" do
          expect(subject.can?(:read, user)).to eq true
          expect(subject.can?(:read, other_user)).to eq true
        end

        it "does not allow read permission on users that are not returned by accessible_users" do
          expect(subject.can?(:read, inaccessible_user)).to eq false
        end
      end
    end

    context "Permissions regarding Role objects" do
      context "AdminRole" do
        let(:target_role) { AdminRole }

        context "current user is an admin" do
          let(:user) { create(:admin_user) }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "anyone else" do
          let(:user) { create(:coalition_lead_user) }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end

      context "CoalitionLeadRole" do
        let(:target_role) { create :coalition_lead_role }
        let(:coalition) { target_role.coalition }

        context "current user is coalition lead in the same coalition" do
          let(:user) { create :coalition_lead_user, coalition: coalition }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is coalition lead in a different coalition" do
          let(:user) { create :coalition_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "anyone else" do
          let(:user) { create :organization_lead_user, organization: build(:organization, coalition: coalition) }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end

      context "OrganizationLeadRole" do
        let(:target_role) { create :organization_lead_role }
        let(:organization) { target_role.organization }

        context "current user is coalition lead in a parent coalition" do
          let(:coalition) { create :coalition, organizations: [organization] }
          let(:user) { create :coalition_lead_user, coalition: coalition }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is coalition lead in a different coalition" do
          let(:user) { create :coalition_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is organization lead in the same organization" do
          let(:user) { create :organization_lead_user, organization: organization }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is organization lead in another organization" do
          let(:user) { create :organization_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "anyone else" do
          let(:user) { create :site_coordinator_user, sites: [create(:site, parent_organization: organization)] }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end

      context "SiteCoordinatorRole" do
        let(:coalition) { create :coalition }
        let(:organization) { create :organization, coalition: coalition }
        let(:another_organization) { create :organization, coalition: coalition }
        let(:site) { create(:site, parent_organization: organization) }
        let(:another_site) { create(:site, parent_organization: organization) }
        let(:target_role) { create :site_coordinator_role, sites: [site] }

        context "current user is coalition lead in the site's coalition" do
          let(:user) { create :coalition_lead_user, coalition: coalition }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is coalition lead in a different coalition" do
          let(:user) { create :coalition_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is organization lead in the site's parent organization" do
          let(:user) { create :organization_lead_user, organization: organization }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is organization lead in another organization" do
          let(:user) { create :organization_lead_user, organization: another_organization }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is site coordinator in the same site" do
          let(:user) { create :site_coordinator_user, sites: [site] }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is site coordinator in another site" do
          let(:user) { create :site_coordinator_user, sites: [another_site] }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "anyone else" do
          let(:user) { create :team_member_user, sites: [site] }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end

      context "TeamMemberRole" do
        let(:coalition) { create :coalition }
        let(:organization) { create :organization, coalition: coalition }
        let(:another_organization) { create :organization, coalition: coalition }
        let(:site) { create(:site, parent_organization: organization) }
        let(:another_site) { create(:site, parent_organization: organization) }
        let(:target_role) { create :team_member_role, sites: [site] }

        context "current user is coalition lead in the site's coalition" do
          let(:user) { create :coalition_lead_user, coalition: coalition }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is coalition lead in a different coalition" do
          let(:user) { create :coalition_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is organization lead in the site's parent organization" do
          let(:user) { create :organization_lead_user, organization: organization }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is organization lead in another organization" do
          let(:user) { create :organization_lead_user, organization: another_organization }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is site coordinator in the same site" do
          let(:user) { create :site_coordinator_user, sites: [site] }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is site coordinator in another site" do
          let(:user) { create :site_coordinator_user, sites: [another_site] }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "anyone else" do
          let(:user) { create :team_member_user, sites: [site] }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end
    end

    context "Permissions regarding StateFile objects" do
      let(:user) { create :team_member_user }

      context "managing StateFile intakes" do
        it "cannot manage state file intakes" do
          expect(subject.can?(:manage, StateFileAzIntake.new)).to eq false
          expect(subject.can?(:manage, StateFileNyIntake.new)).to eq false
          expect(subject.can?(:manage, StateFile1099G.new)).to eq false
          expect(subject.can?(:manage, StateFileDependent.new)).to eq false
          expect(subject.can?(:manage, StateId.new)).to eq false
        end
      end
    end
  end
end
