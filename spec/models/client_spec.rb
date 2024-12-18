# == Schema Information
#
# Table name: clients
#
#  id                                                   :bigint           not null, primary key
#  attention_needed_since                               :datetime
#  completion_survey_sent_at                            :datetime
#  consented_to_service_at                              :datetime
#  ctc_experience_survey_sent_at                        :datetime
#  ctc_experience_survey_variant                        :integer
#  current_sign_in_at                                   :datetime
#  current_sign_in_ip                                   :inet
#  experience_survey                                    :integer          default("unfilled"), not null
#  failed_attempts                                      :integer          default(0), not null
#  filterable_number_of_required_documents              :integer          default(3)
#  filterable_number_of_required_documents_uploaded     :integer          default(0)
#  filterable_percentage_of_required_documents_uploaded :decimal(5, 2)    default(0.0)
#  filterable_product_year                              :integer
#  filterable_tax_return_properties                     :jsonb
#  first_unanswered_incoming_interaction_at             :datetime
#  flagged_at                                           :datetime
#  identity_verification_denied_at                      :datetime
#  identity_verified_at                                 :datetime
#  in_progress_survey_sent_at                           :datetime
#  last_13614c_update_at                                :datetime
#  last_incoming_interaction_at                         :datetime
#  last_internal_or_outgoing_interaction_at             :datetime
#  last_outgoing_communication_at                       :datetime
#  last_seen_at                                         :datetime
#  last_sign_in_at                                      :datetime
#  last_sign_in_ip                                      :inet
#  locked_at                                            :datetime
#  login_requested_at                                   :datetime
#  message_tracker                                      :jsonb
#  needs_to_flush_filterable_properties_set_at          :datetime
#  previous_sessions_active_seconds                     :integer
#  restricted_at                                        :datetime
#  routing_method                                       :integer
#  sign_in_count                                        :integer          default(0), not null
#  still_needs_help                                     :integer          default("unfilled"), not null
#  triggered_still_needs_help_at                        :datetime
#  created_at                                           :datetime         not null
#  updated_at                                           :datetime         not null
#  vita_partner_id                                      :bigint
#
# Indexes
#
#  index_clients_on_consented_to_service_at                      (consented_to_service_at)
#  index_clients_on_filterable_tax_return_properties             (filterable_tax_return_properties) USING gin
#  index_clients_on_fpy_and_first_uii_at                         (filterable_product_year,first_unanswered_incoming_interaction_at) WHERE (consented_to_service_at IS NOT NULL)
#  index_clients_on_fpy_and_in_progress_survey_sent_at           (filterable_product_year,in_progress_survey_sent_at) WHERE (consented_to_service_at IS NOT NULL)
#  index_clients_on_fpy_and_last_outgoing_communication_at       (filterable_product_year,last_outgoing_communication_at) WHERE (consented_to_service_at IS NOT NULL)
#  index_clients_on_fpy_and_required_docs_uploaded               (filterable_product_year,filterable_percentage_of_required_documents_uploaded) WHERE (consented_to_service_at IS NOT NULL)
#  index_clients_on_fpy_and_updated_at                           (filterable_product_year,updated_at) WHERE (consented_to_service_at IS NOT NULL)
#  index_clients_on_in_progress_survey_sent_at                   (in_progress_survey_sent_at)
#  index_clients_on_last_outgoing_communication_at               (last_outgoing_communication_at)
#  index_clients_on_login_token                                  (login_token)
#  index_clients_on_needs_to_flush_filterable_properties_set_at  (needs_to_flush_filterable_properties_set_at)
#  index_clients_on_vita_partner_id                              (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require "rails_helper"

describe Client do
  describe ".sla_tracked scope" do
    let(:client_before_consent) { create(:client, intake: (build :intake)) }
    let(:client_in_progress) { create(:client, intake: (build :intake)) }
    let(:client_file_accepted) { create(:client, intake: (build :intake)) }
    let(:client_file_not_filing) { create(:client, intake: (build :intake)) }
    let(:client_multiple) { create(:client, intake: (build :intake)) }
    let(:client_archived_intake) { create :client, intake: nil }
    let(:client_new_archived_intake) { create :client, intake: build(:intake, product_year: Rails.configuration.product_year - 1) }

    before do
      create :gyr_tax_return, :intake_before_consent, client: client_before_consent
      create :gyr_tax_return, :intake_in_progress, client: client_in_progress
      create :gyr_tax_return, :file_accepted, client: client_file_accepted
      create :gyr_tax_return, :file_not_filing, client: client_file_not_filing
      create :tax_return, :intake_before_consent, year: 2019, client: client_multiple
      create :tax_return, :prep_ready_for_prep, year: 2018, client: client_multiple
      create :tax_return, :prep_ready_for_prep, year: 2020, client: client_archived_intake
      create :tax_return, :prep_ready_for_prep, year: 2020, client: client_new_archived_intake
    end

    it "excludes those with tax returns in :intake_before_consent, :intake_in_progress, :file_accepted, :file_completed" do
      sla_tracked_clients = described_class.sla_tracked
      expect(sla_tracked_clients).to include client_multiple
      expect(sla_tracked_clients).to include client_in_progress
      expect(sla_tracked_clients).not_to include client_file_not_filing
      expect(sla_tracked_clients).not_to include client_file_accepted
      expect(sla_tracked_clients).not_to include client_before_consent
      expect(sla_tracked_clients).not_to include client_archived_intake
      expect(sla_tracked_clients).not_to include client_new_archived_intake
    end
  end

  describe ".refresh_filterable_properties" do
    let(:organization) { create(:organization) }
    let!(:client) { create(:client, vita_partner: organization) }
    let(:user) { create(:user) }
    let!(:tr1) { create(:tax_return, year: 2019, client: client, assigned_user: user) }
    let!(:tr2) { create(:tax_return, :file_needs_review, year: 2020, client: client) }
    let!(:tr3) { create(:tax_return, year: 2018, client: client) }

    before do
      # some (old?) tax returns don't have any transitions and a nil current_state
      tr3.tax_return_transitions.destroy_all
      tr3.update_column(:current_state, nil)
    end

    it "denormalizes filterable properties onto any clients where needs_to_flush_filterable_properties_set_at is set" do
      client.touch(:needs_to_flush_filterable_properties_set_at)
      SearchIndexer.refresh_filterable_properties
      expected_json = [
        {
          "active" => false,
          "year" => 2019,
          "assigned_user_id" => user.id,
          "current_state" => "intake_before_consent",
          "greetable" => false,
          "service_type" => "online_intake",
          "stage" => nil
        },
        {
          "active" => true,
          "year" => 2020,
          "assigned_user_id" => nil,
          "current_state" => "file_needs_review",
          "greetable" => false,
          "service_type" => "online_intake",
          "stage" => "file"
        },
        {
          "active" => false,
          "year" => 2018,
          "assigned_user_id" => nil,
          "current_state" => nil,
          "greetable" => false,
          "service_type" => "online_intake",
          "stage" => nil
        }
      ]
      expect(client.reload.filterable_tax_return_properties).to match_array(expected_json)
      expect(client.reload.vita_partner).to eq(organization) # only change intended columns
    end
  end

  describe "#qualifying_dependents" do
    let(:client) { create :client }

    context "when the tax year does not have rules defined" do
      it "raises an error" do
        expect {
          client.qualifying_dependents(2019)
        }.to raise_error StandardError
      end
    end
  end

  describe "#fraud_suspected?" do
    let(:efile_submission) { create :efile_submission }
    let(:client) { efile_submission.client }
    before do
      stub_const("Fraud::Score::HOLD_THRESHOLD", 50000)
    end

    context "with at least one fraud score over the threshold" do
      before do
        client.fraud_scores.create(score: 130000, efile_submission: efile_submission)
      end

      it "returns true" do
        expect(client.fraud_suspected?).to eq true
      end
    end

    context "with at least one fraud score at the threshold" do
      before do
        client.fraud_scores.create(score: 50000, efile_submission: efile_submission)
      end

      it "returns true" do
        expect(client.fraud_suspected?).to eq true
      end
    end

    context "with no scores at or above the threshold" do
      before do
        client.fraud_scores.create(score: 50, efile_submission: efile_submission)
      end

      it "returns false" do
        expect(client.fraud_suspected?).to eq false
      end
    end
  end

  describe ".with_insufficient_contact_info scope" do
    let!(:client_with_contact_info) { create(:intake, :with_contact_info).client }
    let!(:client_no_info) { create(:intake, email_notification_opt_in: "yes", email_address: nil, sms_notification_opt_in: "yes", sms_phone_number: nil).client }
    let!(:client_no_email) { create(:intake, email_notification_opt_in: "yes", email_address: "").client }
    let!(:client_no_phone) { create(:intake, sms_notification_opt_in: "yes", sms_phone_number: nil).client }
    let!(:client_opted_into_both_but_only_one_contact) {
      create(:intake, email_notification_opt_in: "yes", sms_notification_opt_in: "yes", email_address: nil, sms_phone_number: "+14155537865").client
    }
    let!(:client_no_preferences) {
      create(:intake, email_notification_opt_in: "no", email_address: "irrelevant@example.com", sms_notification_opt_in: "no", sms_phone_number: "+14155537865").client
    }
    let!(:client_no_preferences_no_info) { create(:intake, email_notification_opt_in: "no", email_address: nil, sms_notification_opt_in: "no", sms_phone_number: nil).client }
    let!(:archived_2021_email_client) { create(:client, intake: nil) }
    let!(:archived_2021_email_intake) { create(:archived_2021_gyr_intake, client: archived_2021_email_client, email_address: "someone_archived@example.com", email_notification_opt_in: "yes") }

    it "correctly filters the clients who either haven't opted in or have opted in but without contact info" do
      expect(Client.with_insufficient_contact_info).to match_array [
        client_no_info, client_no_email, client_no_phone, client_no_preferences, client_no_preferences_no_info
      ]
      expect(Client.where.not(id: Client.with_insufficient_contact_info)).to match_array [
        client_with_contact_info, client_opted_into_both_but_only_one_contact, archived_2021_email_client
      ]
    end
  end

  describe "#flagged?" do
    context "when flagged_at is nil" do
      let!(:client) { create :client }

      it "is not flagged" do
        expect(client.flagged?).to eq false
      end
    end

    context "when client has a new document" do
      let!(:client) { create :client }
      before { create :document, client: client, uploaded_by: client }

      it "is flagged" do
        expect(client.flagged?).to eq true
      end
    end

    context "when clients intake was completed" do
      let!(:client) { create :client, intake: build(:intake) }

      it "is not flagged" do
        client.intake.update(completed_at: Time.now)
        expect(client.flagged?).to eq false
      end
    end

    context "when client has a new incoming text message" do
      let!(:client) { create :client }
      before { create :incoming_text_message, client: client }

      it "is flagged" do
        expect(client.flagged?).to eq true
      end
    end

    context "when client has a new incoming email" do
      let!(:client) { create :client }
      before { create :incoming_email, client: client }

      it "is flagged" do
        expect(client.flagged?).to eq true
      end
    end
  end

  describe "#flag!" do
    let(:current_time) { DateTime.new(2021, 2, 23) }
    before { allow(Time).to receive(:now).and_return current_time }

    context "when flagged_at is already present" do
      let(:response_needed_date) { DateTime.new(2021, 2, 21) }
      let(:client) { create :client, flagged_at: response_needed_date }

      it "does not change flagged_at and returns nil" do
        result = client.flag!

        expect(result).to be_nil
        expect(client.reload.flagged_at).to eq response_needed_date
      end
    end

    context "when flagged_at is nil" do
      let(:client) { create :client, flagged_at: nil }

      it "sets response needed to the current time and returns true" do
        result = client.flag!

        expect(result).to eq true
        expect(client.reload.flagged_at).to eq current_time
      end
    end
  end

  describe "#legal_name" do
    let(:client) { create :client, intake: (build :intake, primary_first_name: "  Randall  ", primary_last_name: "Ruttabega  ") }
    it "combines the name and trims whitespace" do
      expect(client.legal_name).to eq "Randall Ruttabega"
    end
  end

  describe "#spouse_legal_name" do
    let(:client) { create :client, intake: (build :intake, spouse_first_name: "Marlie  ", spouse_last_name: "  Mango  ") }
    it "combines the name and trims whitespace" do
      expect(client.spouse_legal_name).to eq "Marlie Mango"
    end
  end

  describe "touch behavior" do
    let!(:client) { create :client }

    describe "incoming text message" do
      it "updates client updated_at" do
        expect { create :incoming_text_message, client: client }.to change(client, :updated_at)
      end

      it "updates client#last_incoming_interaction_at" do
        expect { create :incoming_text_message, client: client }.to change(client, :last_incoming_interaction_at)
      end
    end

    describe "incoming email" do
      it "updates client updated_at" do
        expect { create :incoming_email, client: client }.to change(client, :updated_at)
      end

      it "updates client#last_incoming_interaction_at" do
        expect { create :incoming_email, client: client }.to change(client, :last_incoming_interaction_at)
      end
    end

    describe "outgoing email" do

      before { client.touch(:flagged_at) }
      it "updates client updated_at" do
        expect { create :outgoing_email, client: client }.to change(client, :updated_at)
      end

      it "updates client#last_internal_or_outgoing_interaction_at" do
        expect { create :outgoing_email, client: client }.to change(client, :last_internal_or_outgoing_interaction_at)
      end
    end

    describe "outgoing text" do
      before { client.touch(:flagged_at) }

      it "updates client updated_at" do
        expect { create :note, client: client }.to change(client, :updated_at)
      end

      it "updates client #last_internal_or_outgoing_interaction_at" do
        expect { create :outgoing_text_message, client: client }.to change(client, :last_internal_or_outgoing_interaction_at)
      end
    end

    describe "note" do
      it "updates client updated_at" do
        expect { create :note, client: client }.to change(client, :updated_at)
      end

      it "does not update the flagged_at" do
        expect { create :note, client: client }.not_to change(client, :flagged_at)
      end
    end

    describe "document" do
      context "when a client is uploading a document" do
        it "updates client updated_at" do
          expect { create :document, client: client, uploaded_by: client }.to change(client, :updated_at)
        end

        it "updates client last_incoming_interaction" do
          expect { create :document, client: client, uploaded_by: client }.to change(client, :last_incoming_interaction_at)
        end
      end

      context "when a user is uploading the document" do
        it "does updates client last_internal_or_outgoing_interaction_at" do
          expect { create :document, client: client, uploaded_by: (create :user) }.to change(client, :last_internal_or_outgoing_interaction_at)
        end

        it "touches client updated_at" do
          expect { create :document, client: client, uploaded_by: (create :user) }.to change(client, :updated_at)
        end
      end
    end

    describe "intake" do
      let(:intake) { create :intake, client: client }

      it "does not update client#updated_at until the intake is completed" do
        expect { intake.update(needs_help_2019: "yes") }.not_to change(client, :updated_at)
      end

      context "updating last_incoming_interaction" do
        context "when completed_at is set" do
          it "does not update the responded at value" do
            expect { intake.update(completed_at: Time.now) }.to change(intake.client, :last_incoming_interaction_at)
          end
        end

        context "completed_at is not set" do
          it "updated client#last_incoming_interaction" do
            expect { intake.update(needs_help_2019: "yes") }.not_to change(intake.client, :last_incoming_interaction_at)
          end
        end
      end
    end
  end

  describe "#destroy" do
    context "with many associated records" do
      let(:vita_partner) { create :site }
      let(:user) { create :user }
      let(:organization_lead_role) { create :organization_lead_role, user: user, organization: vita_partner }
      let(:client) { create :client, vita_partner: vita_partner }
      let(:intake) { create :intake, client: client, vita_partner: vita_partner }
      let!(:unrelated_intake) { create :intake }
      let(:attachment) { fixture_file_upload("test-pattern.png") }
      let(:tax_return_selection) { create(:tax_return_selection) }
      let(:outgoing_email) { create(:outgoing_email, client: client) }
      let!(:bulk_client_message) { BulkClientMessageOutgoingEmail.create(outgoing_email: outgoing_email)}
      let(:bulk_client_message) { BulkClientMessage.create }
      let!(:outgoing_text_message) { create(:outgoing_text_message, client: client) }
      let!(:bulk_client_sms) { BulkClientMessageOutgoingTextMessage.create(outgoing_text_message: outgoing_text_message) }
      before do
        doc_request = DocumentsRequest.create(client: client)
        create :document, client: client, intake: intake, documents_request_id: doc_request.id
        create_list :document, 2, client: client, intake: intake
        create_list :dependent, 2, intake: intake
        tax_return = create :gyr_tax_return, client: client, assigned_user: user, tax_return_selections: [tax_return_selection]
        tax_return_assignment = create :tax_return_assignment, tax_return: tax_return
        create :user_notification, user: user, notifiable: tax_return_assignment
        submission = create :efile_submission, :investigating, tax_return: tax_return
        create :address, record: submission
        create_list :document, 2, client: client, intake: intake, tax_return: tax_return
        note = create :note, client: client, user: user
        create :user_notification, user: user, notifiable: note
        create :system_note, client: client
        create :incoming_email, client: client
        create :incoming_text_message, client: client
        create :outgoing_email, client: client, attachment: attachment
        create :outgoing_text_message, client: client
      end

      it "destroys everything associated with the client" do
        client.destroy
        expect(Client.count).to eq 1
        expect(EfileSecurityInformation.count).to eq 1
        expect(Client.last).to eq unrelated_intake.client
        expect(Intake.count).to eq 1
        expect(Intake.last).to eq unrelated_intake
        expect(Document.count).to eq 0
        expect(Dependent.count).to eq 0
        expect(TaxReturn.count).to eq 0
        expect(Note.count).to eq 0
        expect(SystemNote.count).to eq 0
        expect(IncomingEmail.count).to eq 0
        expect(IncomingTextMessage.count).to eq 0
        expect(OutgoingEmail.count).to eq 0
        expect(OutgoingTextMessage.count).to eq 0
        expect(DocumentsRequest.count).to eq 0
        expect(TaxReturnAssignment.count).to eq 0
        expect(UserNotification.count).to eq 0
        expect(Address.count).to eq(0)
        expect(EfileSubmission.count).to eq(0)
      end
    end
  end

  describe "#by_contact_info" do
    context "given an email" do
      let(:email_address) { "client@example.com" }

      context "with a client whose email matches" do
        let!(:client) { create(:client, intake: build(:intake, email_address: email_address)) }

        it "finds the client" do
          expect(described_class.by_contact_info(email_address: "client@example.com", phone_number: nil)).to include(client)
        end
      end

      context "with a client whose spouse email matches" do
        let!(:client) { create(:client, intake: build(:intake, spouse_email_address: email_address)) }

        it "finds the client" do
          expect(described_class.by_contact_info(email_address: "client@example.com", phone_number: nil)).to include(client)
        end
      end
    end

    context "given a phone number" do
      let(:phone_number) { "+15105551234" }

      context "with a client whose phone_number matches" do
        let!(:client) { create(:client, intake: build(:intake, phone_number: phone_number))}

        it "finds the client" do
          expect(described_class.by_contact_info(email_address: nil, phone_number: phone_number)).to include(client)
        end
      end

      context "with a client whose sms_phone_number matches" do
        let!(:client) { create(:client, intake: build(:intake, sms_phone_number: phone_number))}

        it "finds the client" do
          expect(described_class.by_contact_info(email_address: nil, phone_number: phone_number)).to include(client)
        end
      end
    end
  end

  describe "#clients_with_dupe_ssn" do
    let(:primary_ssn) { "311456789" }
    let(:product_year) { Rails.configuration.product_year }
    let!(:ctc_client_accessible_ssn_match) { create :client, intake: build(:ctc_intake, product_year: product_year, primary_ssn: primary_ssn, sms_phone_number_verified_at: DateTime.now) }
    let!(:ctc_client_accessible_ssn_match_old_product_year) { create :client, intake: build(:ctc_intake, product_year: product_year - 1, primary_ssn: primary_ssn, sms_phone_number_verified_at: DateTime.now) }
    let!(:ctc_client_inaccessible_ssn_match) { create :client, intake: build(:ctc_intake, product_year: product_year, primary_ssn: primary_ssn, sms_phone_number_verified_at: nil, email_address_verified_at: nil, navigator_has_verified_client_identity: nil) }
    let!(:ctc_client_accessible_no_ssn_match) { create :client, intake: build(:ctc_intake, product_year: product_year, primary_ssn: "123456789", sms_phone_number_verified_at: DateTime.now) }

    let!(:gyr_client_accessible_ssn_match_online) { create :client, :with_gyr_return, intake: build(:intake, product_year: product_year, primary_ssn: primary_ssn, primary_consented_to_service: "yes"), tax_returns: [(build :tax_return, service_type: "online_intake", year: 2019)] }
    let!(:gyr_client_accessible_ssn_match_drop_off) { create :client, :with_gyr_return, intake: build(:intake, product_year: product_year, primary_ssn: primary_ssn, primary_consented_to_service: "yes"), tax_returns: [(build :tax_return, service_type: "drop_off", year: 2019)] }
    let!(:gyr_client_accessible_ssn_match_old_product_year) { create :client, :with_gyr_return, intake: build(:intake, product_year: product_year - 1, primary_ssn: primary_ssn, primary_consented_to_service: "yes"), tax_returns: [(build :tax_return, service_type: "drop_off", year: 2019)] }
    let!(:gyr_client_inaccessible_ssn_match) { create :client, :with_gyr_return, intake: build(:intake, product_year: product_year, primary_ssn: primary_ssn, primary_consented_to_service: "unfilled"), tax_returns: [(build :tax_return, service_type: "online_intake", year: 2019)] }
    let!(:gyr_client_accessible_no_ssn_match) { create :client, :with_gyr_return, intake: build(:intake, product_year: product_year, primary_ssn: "123456789", primary_consented_to_service: "yes"), tax_returns: [(build :tax_return, service_type: "drop_off", year: 2019)] }

    context "GYR client" do
      let!(:client) { create :client, filterable_product_year: product_year, intake: build(:intake, primary_ssn: primary_ssn, product_year: product_year) }

      context "looking for CTC matches" do
        let(:display_type) { Intake::CtcIntake }

        context "with a product year of 2023" do
          it "returns no CTC clients because the current product year for CTC is still 2022" do
            expect(client.clients_with_dupe_ssn(display_type)).to be_empty
          end
        end

        context "with a product year of 2022" do
          let(:product_year) { 2022 }
          it "returns accessible CTC clients with the same ssn for the current product year" do
            expect(client.clients_with_dupe_ssn(display_type)).to include ctc_client_accessible_ssn_match
            expect(client.clients_with_dupe_ssn(display_type)).not_to include(ctc_client_inaccessible_ssn_match, ctc_client_accessible_no_ssn_match, ctc_client_accessible_ssn_match_old_product_year, gyr_client_accessible_ssn_match_online, gyr_client_accessible_ssn_match_old_product_year)
          end
        end
      end

      context "looking for GYR matches" do
        let(:display_type) { Intake::GyrIntake }
        it "returns accessible GYR clients with the same ssn for the current product year" do
          expect(client.clients_with_dupe_ssn(display_type)).to include(gyr_client_accessible_ssn_match_online, gyr_client_accessible_ssn_match_drop_off)
          expect(client.clients_with_dupe_ssn(display_type)).not_to include(gyr_client_inaccessible_ssn_match, gyr_client_accessible_no_ssn_match, gyr_client_accessible_ssn_match_old_product_year, ctc_client_accessible_ssn_match, ctc_client_accessible_ssn_match_old_product_year)
        end
      end
    end

    context "CTC client" do
      let!(:client) { create :client, filterable_product_year: product_year, intake: build(:ctc_intake, primary_ssn: primary_ssn, product_year: product_year) }

      context "looking for CTC matches" do
        let(:display_type) { Intake::CtcIntake }

        context "with a product year of 2023" do
          it "returns no CTC clients because the current product year for CTC is still 2022" do
            expect(client.clients_with_dupe_ssn(display_type)).to be_empty
          end
        end

        context "with a product year of 2022" do
          let(:product_year) { 2022 }
          it "returns accessible CTC clients with the same ssn for the current product year" do
            expect(client.clients_with_dupe_ssn(display_type)).to include ctc_client_accessible_ssn_match
            expect(client.clients_with_dupe_ssn(display_type)).not_to include(ctc_client_inaccessible_ssn_match, ctc_client_accessible_no_ssn_match, ctc_client_accessible_ssn_match_old_product_year, gyr_client_accessible_ssn_match_online, gyr_client_accessible_ssn_match_old_product_year)
          end
        end
      end

      context "looking for GYR matches" do
        let(:display_type) { Intake::GyrIntake }

        it "returns accessible GYR clients with the same ssn for the current product year" do
          expect(client.clients_with_dupe_ssn(display_type)).to include(gyr_client_accessible_ssn_match_online, gyr_client_accessible_ssn_match_drop_off)
          expect(client.clients_with_dupe_ssn(display_type)).not_to include(gyr_client_inaccessible_ssn_match, gyr_client_accessible_no_ssn_match, gyr_client_accessible_ssn_match_old_product_year, ctc_client_accessible_ssn_match, ctc_client_accessible_ssn_match_old_product_year)
        end
      end
    end

    context "there are no other clients with a matching SSN" do
      let!(:client) { create :client, intake: build(:ctc_intake, primary_ssn: "987654111") }

      it "returns an empty collection" do
        expect(client.clients_with_dupe_ssn(Intake::GyrIntake)).to be_empty
        expect(client.clients_with_dupe_ssn(Intake::CtcIntake)).to be_empty
      end
    end

    context "there is a matching intake with nil client" do
      let!(:client) { create :client, intake: build(:ctc_intake, primary_ssn: "987654111") }
      let!(:intake) { create :intake, primary_ssn: "987654111", client: nil }

      it "returns an empty collection" do
        expect(client.clients_with_dupe_ssn(Intake::GyrIntake)).to be_empty
        expect(client.clients_with_dupe_ssn(Intake::CtcIntake)).to be_empty
      end
    end

    context "no primary ssn provided" do
      let!(:client) { create :client, intake: build(:ctc_intake, primary_ssn: nil) }

      it "does not match on nil values" do
        expect(client.clients_with_dupe_ssn(Intake::GyrIntake)).to be_empty
        expect(client.clients_with_dupe_ssn(Intake::CtcIntake)).to be_empty
      end
    end
  end

  describe ".locale_counts" do
    let(:organization) { create(:organization) }
    context "with all languages present" do
      before do
        create(:client, intake: build(:intake, locale: "en"), vita_partner: nil)
        create(:client, intake: build(:intake, locale: "en"), vita_partner: organization)
        create(:client, intake: build(:intake, locale: "es"), vita_partner: organization)
        create(:client, intake: build(:intake, locale: nil), vita_partner: organization)
        create(:archived_2021_gyr_intake, locale: "en", client: create(:client, intake: nil, vita_partner: organization))
      end

      it "takes locales and counts them into a hash, counting nil as en" do
        expect(Client.where(vita_partner: organization).locale_counts).to eq({ "en" => 3, "es" => 1})
      end
    end

    context "with only one language present" do
      before do
        create(:client, intake: build(:intake, locale: "en"))
        create(:client, intake: build(:intake, locale: nil))
      end

      it "returns a hash with both en & es" do
        expect(Client.all.locale_counts).to eq({ "en" => 2, "es" => 0})
      end
    end
  end

  describe "#forward_message_to_intercom?" do
    context "an online CTC client" do
      let(:client) { create :client, intake: build(:ctc_intake), tax_returns: [build(:ctc_tax_return, service_type: "online_intake")] }

      it "returns false" do
        expect(client.forward_message_to_intercom?).to eq(false)
      end
    end

    context "a dropoff client" do
      let(:client) { create :client, intake: build(:intake), tax_returns: tax_returns }
      let(:tax_returns) { [build(:tax_return, status1.to_sym, year: "2019"), build(:tax_return, status2.to_sym, year: "2020")] }

      context "when the FORWARD_MESSAGES_TO_INTERCOM admin toggle is true" do
        before do
          AdminToggle.create(name: AdminToggle::FORWARD_MESSAGES_TO_INTERCOM, value: true, user: create(:admin_user))
        end

        context "some of the tax returns have FORWARD_TO_INTERCOM statuses" do
          let(:status1) { "file_not_filing" }
          let(:status2) { "review_reviewing" }

          it "returns false" do
            expect(client.forward_message_to_intercom?).to eq(false)
          end
        end

        context "none of the tax returns have FORWARD_TO_INTERCOM statuses" do
          let(:status1) { "review_reviewing" }
          let(:status2) { "file_hold" }

          it "returns false" do
            expect(client.forward_message_to_intercom?).to eq(false)
          end
        end

        context "all tax returns have FORWARD_TO_INTERCOM statuses" do
          let(:status1) { "file_not_filing" }
          let(:status2) { "file_accepted" }

          it "returns true" do
            expect(client.forward_message_to_intercom?).to eq(true)
          end
        end
      end

      context "when the FORWARD_MESSAGES_TO_INTERCOM admin toggle is false" do
        let(:status1) { "file_not_filing" }
        let(:status2) { "file_accepted" }

        before do
          AdminToggle.create(name: AdminToggle::FORWARD_MESSAGES_TO_INTERCOM, value: false, user: create(:admin_user))
        end

        it "returns false" do
          expect(client.forward_message_to_intercom?).to eq(false)
        end
      end
    end
  end

  describe "#request_doc_help" do
    let(:client) { create :client, intake: (build :intake) }
    let(:assigned_user_a) { create :user }
    let(:assigned_user_b) { create :user }
    before do
      create :tax_return, year: 2019, assigned_user: assigned_user_a, client: client
      create :tax_return, year: 2018, assigned_user: assigned_user_b, client: client
      create :gyr_tax_return, assigned_user: assigned_user_a, client: client
    end

    context "with valid data" do
      it "creates a system note, user notifications, changes tax return statuses, and sets response needed" do
        expect {
          client.request_document_help(doc_type: DocumentTypes::Employment, help_type: "cant_locate")
          assigned_user_a.reload
          assigned_user_b.reload
        }.to change(SystemNote::DocumentHelp, :count).by(1)
         .and change(assigned_user_a.notifications, :count).by(1)
         .and change(assigned_user_b.notifications, :count).by(1)
        expect(assigned_user_a.notifications.last.notifiable).to eq SystemNote::DocumentHelp.last
        expect(assigned_user_b.notifications.last.notifiable).to eq SystemNote::DocumentHelp.last
        expect(client.tax_returns.map(&:current_state).uniq).to eq ["intake_needs_doc_help"]
      end
    end

    context "with invalid data" do
      context "invalid doc_type" do
        it "raises an ArgumentError" do
          expect {
            client.request_document_help(doc_type: "employment", help_type: "cant_locate")
          }.to raise_error(ArgumentError)
        end
      end

      context "invalid help_type" do
        it "raises an ArgumentError" do
          expect {
            client.request_document_help(doc_type: "Employment", help_type: "cant_locate")
          }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '#previous_sessions_active_seconds' do
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }
    let(:client) { create :client, last_sign_in_at: fake_time - 5.minutes, last_seen_at: fake_time }

    around do |example|
      Timecop.freeze(fake_time) { example.run }
    end

    it 'accumulates the last session length on every login' do
      expect do
        client.accumulate_total_session_durations
      end.to change { client.reload.previous_sessions_active_seconds }.from(nil).to(5 * 60)
    end
  end

  describe "#accumulate_total_session_durations" do
    context "previous_session_duration is negative" do
      let(:client) { create :client, last_sign_in_at: last_sign_in_at, last_seen_at: last_seen_at, previous_sessions_active_seconds: 5400 }
      let(:last_seen_at) {Time.utc(2021, 2, 5, 0, 0, 0)}
      let(:last_sign_in_at) {Time.utc(2021, 2, 6, 0, 0, 0)}

      it "should not store the previous_sessions_active_seconds" do
        expect do
          client.accumulate_total_session_durations
        end.not_to change { client.reload.previous_sessions_active_seconds }
      end
    end
  end

  describe "#number_of_required_documents" do
    context "for a single filer" do
      let(:minimal_intake) { create(:intake, {}) }

      it "includes the documents that are required for everyone" do
        expect(minimal_intake.client.number_of_required_documents).to eq(3)
      end
    end

    context "filing jointly" do
      let(:joint_intake) { create(:intake, filing_joint: "yes") }

      it "returns at least six, for the three required documents for each filer" do
        expect(joint_intake.client.number_of_required_documents).to eq(6)
      end
    end

    context "filing with dependents" do
      let(:dependents_intake) { create(:intake, {}) }
      let!(:dependent1) { create :dependent, intake: dependents_intake }
      let!(:dependent2) { create :dependent, intake: dependents_intake }

      it "requires an additional document (SSN) for each dependent" do
        expect(dependents_intake.client.number_of_required_documents).to eq(5)
      end
    end

    context "when answering questions that require additional forms" do
      let(:health_and_wages_intake) { create(:intake, bought_marketplace_health_insurance: "yes", had_wages: "yes") }

      it "returns expected documents for particular intake forms" do
        expect(health_and_wages_intake.client.number_of_required_documents).to eq(5)
      end
    end
  end

  describe "#number_of_required_documents_uploaded" do
    let(:intake) { create(:intake) }

    it "returns zero when no required documents are uploaded" do
      expect(intake.client.number_of_required_documents_uploaded).to eq(0)
    end

    context "with uploaded documents" do
      it "returns the number of uploaded documents" do
        expect do
          create :document, intake: intake, document_type: DocumentTypes::Selfie.key
        end.to change { intake.reload.client.number_of_required_documents_uploaded }.from(0).to(1)

        expect(intake.client.number_of_required_documents_uploaded).to eq(1)
      end

      context "when multiple documents are required of the same type" do
        let(:dependents_intake) { create(:intake, {}) }
        let!(:dependent1) { create :dependent, intake: dependents_intake }
        let!(:dependent2) { create :dependent, intake: dependents_intake }

        it "counts all documents up to the # required but no more" do
          # One SsnItin for the primary filer and each dependent
          expect do
            create :document, intake: dependents_intake, document_type: DocumentTypes::SsnItin.key
            create :document, intake: dependents_intake, document_type: DocumentTypes::SsnItin.key
            create :document, intake: dependents_intake, document_type: DocumentTypes::SsnItin.key
          end.to change { dependents_intake.reload.client.number_of_required_documents_uploaded }.from(0).to(3)

          # Additional SsnItin do not contribute
          expect do
            create :document, intake: dependents_intake, document_type: DocumentTypes::SsnItin.key
          end.not_to change { dependents_intake.reload.client.number_of_required_documents_uploaded }
        end
      end
    end
  end

  describe "#required_document_counts" do
    before do
      ExperimentService.ensure_experiments_exist_in_database
      Experiment.update_all(enabled: true)
    end

    let(:treatment) { "control" }
    let(:experiment) { Experiment.find_by(key: ExperimentService::ID_VERIFICATION_EXPERIMENT) }
    let!(:experiment_participant) do
      create :experiment_participant,
             experiment: experiment,
             treatment: treatment,
             record: client.intake
    end
    let!(:client) { create :client, intake: build(:intake) }

    context "client is in the ID Verification Experiment" do
      context "has control treatment" do
        it "does include selfie doc" do
          expect(client.required_document_counts).to have_key("Selfie")
        end
      end

      context "has no_selfie treatment" do
        let(:treatment) { "no_selfie" }
        it "does not include selfie doc" do
          expect(client.required_document_counts).not_to have_key("Selfie")
        end
      end

      context "has expanded_id treatment" do
        let(:treatment) { "expanded_id" }
        it "does include selfie doc" do
          expect(client.required_document_counts).to have_key("Selfie")
        end
      end

      context "has expanded_id_and_no_selfie treatment" do
        let(:treatment) { "expanded_id_and_no_selfie" }
        it "does not include selfie doc" do
          expect(client.required_document_counts).not_to have_key("Selfie")
        end
      end
    end

    context "client is in the Returning Client Experiment" do
      let(:experiment) { Experiment.find_by(key: ExperimentService::RETURNING_CLIENT_EXPERIMENT) }

      context "has control treatment" do
        it "does include selfie doc" do
          expect(client.required_document_counts).to have_key("Selfie")
        end
      end

      context "has skip_identity_documents treatment" do
        let(:treatment) { "skip_identity_documents" }
        it "does not include selfie doc" do
          expect(client.required_document_counts).not_to have_key("Selfie")
        end
      end
    end

    context "acceptable alternatives for certain identity docs" do
      context "client uploaded a drivers license doc" do
        let!(:driver_license_doc) { create :document, client: client, intake: client.intake, document_type: DocumentTypes::PrimaryIdentification::DriversLicense.key }

        it "counts the drivers license as an ID document" do
          expect(client.required_document_counts).to match(hash_including("ID"=>{:clamped_provided_count=>1, :provided_count=>1, :required_count=>1}))
        end
      end

      context "client uploaded a drivers license doc" do
        let!(:w2_doc) { create :document, client: client, intake: client.intake, document_type: DocumentTypes::SecondaryIdentification::W2.key }

        it "counts it as an 'SSN or ITIN' document" do
          expect(client.required_document_counts).to match(hash_including("SSN or ITIN" => {:clamped_provided_count=>1, :provided_count=>1, :required_count=>1}))
        end
      end
    end
  end
end
