# == Schema Information
#
# Table name: clients
#
#  id                                       :bigint           not null, primary key
#  attention_needed_since                   :datetime
#  current_sign_in_at                       :datetime
#  current_sign_in_ip                       :inet
#  failed_attempts                          :integer          default(0), not null
#  first_unanswered_incoming_interaction_at :datetime
#  last_incoming_interaction_at             :datetime
#  last_internal_or_outgoing_interaction_at :datetime
#  last_sign_in_at                          :datetime
#  last_sign_in_ip                          :inet
#  locked_at                                :datetime
#  login_requested_at                       :datetime
#  login_token                              :string
#  response_needed_since                    :datetime
#  routing_method                           :integer
#  sign_in_count                            :integer          default(0), not null
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  vita_partner_id                          :bigint
#
# Indexes
#
#  index_clients_on_login_token      (login_token)
#  index_clients_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require "rails_helper"

describe Client do
  describe "valid?" do
    context "when assigning to a new partner would remove access for a tax return assignee" do
      let(:current_site) { create :site }
      let(:client) { create :client, vita_partner: current_site }
      let(:other_site) { create :site, parent_organization: current_site.parent_organization }
      let(:assigned_user) { create :team_member_user, site: current_site }
      let(:another_assigned_user) { create :site_coordinator_user, site: current_site }
      before do
        create :tax_return, year: 2019, client: client, assigned_user: assigned_user
        create :tax_return, year: 2020, client: client, assigned_user: another_assigned_user
      end

      it "adds a useful validation error message to vita_partner" do
        client.vita_partner = other_site

        expect(client).not_to be_valid
        access_loss_error_message = client.errors[:vita_partner_id][0]
        expect(access_loss_error_message).to include assigned_user.name
        expect(access_loss_error_message).to include another_assigned_user.name
        expect(access_loss_error_message).to include "would lose access if you assign this client to "\
          "#{other_site.name}. Please change tax return assignments before reassigning this client."

      end
    end
  end

  describe ".sla_tracked scope" do
    let(:client_before_consent) { create(:client) }
    let(:client_in_progress) { create(:client) }
    let(:client_file_accepted) { create(:client) }
    let(:client_file_not_filing) { create(:client) }
    let(:client_multiple) { create(:client) }

    before do
      create :tax_return, status: :intake_before_consent, client: client_before_consent
      create :tax_return, status: :intake_in_progress, client: client_in_progress
      create :tax_return, status: :file_accepted, client: client_file_accepted
      create :tax_return, status: :file_not_filing, client: client_file_not_filing
      create :tax_return, year: 2019, status: :intake_before_consent, client: client_multiple
      create :tax_return, year: 2018, status: :prep_ready_for_prep, client: client_multiple
    end

    it "excludes those with tax returns in :intake_before_consent, :intake_in_progress, :file_accepted, :file_completed" do
      sla_tracked_clients = described_class.sla_tracked
      expect(sla_tracked_clients).to include client_multiple
      expect(sla_tracked_clients).to include client_in_progress
      expect(sla_tracked_clients).not_to include client_file_not_filing
      expect(sla_tracked_clients).not_to include client_file_accepted
      expect(sla_tracked_clients).not_to include client_before_consent
    end
  end

  describe "#needs_response?" do
    context "when last_response_at is nil" do
      let!(:client) { create :client }

      it "doesn't need response" do
        expect(client.needs_response?).to eq false
      end
    end

    context "when client has a new document" do
      let!(:client) { create :client }
      before { create :document, client: client, uploaded_by: client }

      it "needs response" do
        expect(client.needs_response?).to eq true
      end
    end

    context "when clients intake was completed" do
      let!(:client) { create :client, intake: create(:intake) }

      it "needs response" do
        client.intake.update(completed_at: Time.now)
        expect(client.needs_response?).to eq true
      end
    end

    context "when client has a new incoming text message" do
      let!(:client) { create :client }
      before { create :incoming_text_message, client: client }

      it "needs response" do
        expect(client.needs_response?).to eq true
      end
    end

    context "when client has a new incoming email" do
      let!(:client) { create :client }
      before { create :incoming_email, client: client }

      it "needs response" do
        expect(client.needs_response?).to eq true
      end
    end

    context "when client has a new outgoing email" do
      let!(:client) { create :client }
      before { create :outgoing_email, client: client }

      it "doesn't need response" do
        expect(client.needs_response?).to eq false
      end
    end

    context "when client has a new outgoing text" do
      let!(:client) { create :client }
      before { create :outgoing_email, client: client }

      it "doesn't need response" do
        expect(client.needs_response?).to eq false
      end
    end
  end

  describe "#set_response_needed!" do
    let(:current_time) { DateTime.new(2021, 2, 23) }
    before { allow(Time).to receive(:now).and_return current_time }

    context "when response_needed_since is already present" do
      let(:response_needed_date) { DateTime.new(2021, 2, 21) }
      let(:client) { create :client, response_needed_since: response_needed_date }

      it "does not change response needed and returns nil" do
        result = client.set_response_needed!

        expect(result).to be_nil
        expect(client.reload.response_needed_since).to eq response_needed_date
      end
    end

    context "when response_needed_since is nil" do
      let(:client) { create :client, response_needed_since: nil }

      it "sets response needed to the current time and returns true" do
        result = client.set_response_needed!

        expect(result).to eq true
        expect(client.reload.response_needed_since).to eq current_time
      end
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

      it "updates client#response_needed_since" do
        expect { create :incoming_email, client: client }.to change(client, :response_needed_since)
      end
    end

    describe "incoming email" do
      it "updates client updated_at" do
        expect { create :incoming_email, client: client }.to change(client, :updated_at)
      end

      it "updates client#last_incoming_interaction_at" do
        expect { create :incoming_email, client: client }.to change(client, :last_incoming_interaction_at)
      end

      it "updates client#response_needed_since" do
        expect { create :incoming_email, client: client }.to change(client, :response_needed_since)
      end
    end

    describe "outgoing email" do

      before { client.touch(:response_needed_since) }
      it "updates client updated_at" do
        expect { create :outgoing_email, client: client }.to change(client, :updated_at)
      end

      it "updates client#last_internal_or_outgoing_interaction_at" do
        expect { create :outgoing_email, client: client }.to change(client, :last_internal_or_outgoing_interaction_at)
      end

      it "clears #response_needed_since" do
        create :outgoing_email, client: client
        expect(client.response_needed_since).to be nil
      end
    end

    describe "outgoing text" do
      before { client.touch(:response_needed_since) }

      it "updates client updated_at" do
        expect { create :note, client: client }.to change(client, :updated_at)
      end

      it "updates client #last_internal_or_outgoing_interaction_at" do
        expect { create :outgoing_text_message, client: client }.to change(client, :last_internal_or_outgoing_interaction_at)
      end

      it "clears response_needed_since" do
        create :outgoing_text_message, client: client
        expect(client.response_needed_since).to be nil
      end
    end

    describe "note" do
      it "updates client updated_at" do
        expect { create :note, client: client }.to change(client, :updated_at)
      end

      it "does not update the response_needed_since" do
        expect { create :note, client: client }.not_to change(client, :response_needed_since)
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

        it "updates client response_needed_since" do
          expect { create :document, client: client, uploaded_by: client }.to change(client, :response_needed_since)

        end

        context "without an explicit relationship to client but an intake that has a client id" do
          let(:client) { create :client, intake: create(:intake) }
          it "still should update the associated client" do
            expect { create :document, intake: client.intake, uploaded_by: client }.to change(client, :response_needed_since)
          end
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

  describe "#destroy_completely" do
    context "with many associated records" do
      let(:vita_partner) { create :vita_partner }
      let(:user) { create :user }
      let(:organization_lead_role) { create :organization_lead_role, user: user, organization: vita_partner }
      let(:client) { create :client, vita_partner: vita_partner }
      let(:intake) { create :intake, client: client, vita_partner: vita_partner }
      let!(:unrelated_intake) { create :intake }
      let(:attachment) { fixture_file_upload("attachments/test-pattern.png") }
      before do
        create_list :document, 2, client: client, intake: intake
        create_list :dependent, 2, intake: intake
        create :tax_return, client: client, assigned_user: user
        create :note, client: client, user: user
        create :system_note, client: client
        create :incoming_email, client: client
        create :incoming_text_message, client: client
        create :outgoing_email, client: client, attachment: attachment
        create :outgoing_text_message, client: client
        create :documents_request, intake: intake
      end

      it "destroys everything associated with the client" do
        client.destroy_completely
        expect(Client.count).to eq 1
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
      end
    end
  end

  describe "#by_contact_info" do
    context "given an email" do
      let(:email_address) { "client@example.com" }

      context "with a client whose email matches" do
        let!(:client) { create(:client, intake: create(:intake, email_address: email_address))}

        it "finds the client" do
          expect(described_class.by_contact_info(email_address: "client@example.com", phone_number: nil)).to include(client)
        end
      end

      context "with a client whose spouse email matches" do
        let!(:client) { create(:client, intake: create(:intake, spouse_email_address: email_address))}

        it "finds the client" do
          expect(described_class.by_contact_info(email_address: "client@example.com", phone_number: nil)).to include(client)
        end
      end
    end

    context "given a phone number" do
      let(:phone_number) { "+15105551234" }

      context "with a client whose phone_number matches" do
        let!(:client) { create(:client, intake: create(:intake, phone_number: phone_number))}

        it "finds the client" do
          expect(described_class.by_contact_info(email_address: nil, phone_number: phone_number)).to include(client)
        end
      end

      context "with a client whose sms_phone_number matches" do
        let!(:client) { create(:client, intake: create(:intake, sms_phone_number: phone_number))}

        it "finds the client" do
          expect(described_class.by_contact_info(email_address: nil, phone_number: phone_number)).to include(client)
        end
      end
    end
  end

  describe "#generate_login_link" do
    let(:fake_time) { DateTime.new(2021, 1, 1) }
    let(:client) { build(:client) }

    before do
      allow(Devise.token_generator).to receive(:generate).and_return(['raw_token', 'encrypted_token'])
      allow(DateTime).to receive(:now).and_return(fake_time)
    end

    it "generates a new login URL" do
      login_url = client.generate_login_link
      expect(login_url).to eq("http://test.host/en/portal/account/raw_token")
      expect(Devise.token_generator).to have_received(:generate).with(Client, :login_token)
      expect(client.reload.login_token).to eq('encrypted_token')
      expect(client.reload.login_requested_at).to eq(fake_time)
    end
  end
end
