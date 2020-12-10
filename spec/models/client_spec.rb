# == Schema Information
#
# Table name: clients
#
#  id                           :bigint           not null, primary key
#  attention_needed_since       :datetime
#  last_incoming_interaction_at :datetime
#  last_interaction_at          :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  vita_partner_id              :bigint
#
# Indexes
#
#  index_clients_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require "rails_helper"

describe Client do
  describe "#needs_attention" do

    context "when last_response_at is nil" do
      let!(:client) { create :client }

      it "doesn't need attention" do
        expect(client.needs_attention?).to eq false
      end
    end

    context "when client has a new document" do
      let!(:client) { create :client }
      before { create :document, client: client }

      it "needs attention" do
        expect(client.needs_attention?).to eq true
      end
    end

    context "when clients intake was completed" do
      let!(:client) { create :client, intake: create(:intake) }

      it "needs attention" do
        client.intake.update(completed_at: Time.now)
        expect(client.needs_attention?).to eq true
      end
    end

    context "when client has a new incoming text message" do
      let!(:client) { create :client }
      before { create :incoming_text_message, client: client }

      it "needs attention" do
        expect(client.needs_attention?).to eq true
      end
    end

    context "when client has a new incoming email" do
      let!(:client) { create :client }
      before { create :incoming_email, client: client }

      it "needs attention" do
        expect(client.needs_attention?).to eq true
      end
    end

    context "when client has a new outgoing email" do
      let!(:client) { create :client }
      before { create :outgoing_email, client: client }

      it "doesn't need attention" do
        expect(client.needs_attention?).to eq false
      end
    end

    context "when client has a new outgoing text" do
      let!(:client) { create :client }
      before { create :outgoing_email, client: client }

      it "doesn't need attention" do
        expect(client.needs_attention?).to eq false
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

      it "updates client#attention_needed_since" do
        expect { create :incoming_email, client: client }.to change(client, :attention_needed_since)
      end
    end

    describe "incoming email" do
      it "updates client updated_at" do
        expect { create :incoming_email, client: client }.to change(client, :updated_at)
      end

      it "updates client#last_incoming_interaction_at" do
        expect { create :incoming_email, client: client }.to change(client, :last_incoming_interaction_at)
      end

      it "updates client#attention_needed_since" do
        expect { create :incoming_email, client: client }.to change(client, :attention_needed_since)
      end
    end

    describe "outgoing email" do

      before { client.touch(:attention_needed_since) }
      it "updates client updated_at" do
        expect { create :outgoing_email, client: client }.to change(client, :updated_at)
      end

      it "updates client#last_interaction_at" do
        expect { create :outgoing_email, client: client }.to change(client, :last_interaction_at)
      end

      it "clears #attention_needed_since" do
        create :outgoing_email, client: client
        expect(client.attention_needed_since).to be nil
      end
    end

    describe "outgoing text" do
      before { client.touch(:attention_needed_since) }

      it "updates client updated_at" do
        expect { create :note, client: client }.to change(client, :updated_at)
      end

      it "updates client #last_interaction_at" do
        expect { create :outgoing_text_message, client: client }.to change(client, :last_interaction_at)
      end

      it "clears attention_needed_since" do
        create :outgoing_text_message, client: client
        expect(client.attention_needed_since).to be nil
      end
    end

    describe "note" do
      it "updates client updated_at" do
        expect { create :note, client: client }.to change(client, :updated_at)
      end

      it "updates client last_interaction_at" do
        expect { create :note, client: client }.to change(client, :last_interaction_at)
      end

      it "does not update the attention_needed_since" do
        expect { create :note, client: client }.not_to change(client, :attention_needed_since)
      end
    end

    describe "document" do
      it "updates client updated_at" do
        expect { create :document, client: client }.to change(client, :updated_at)
      end

      it "updates client last_interaction_at" do
        expect { create :document, client: client }.to change(client, :last_interaction_at)
      end

      it "updates client last_incoming_interaction" do
        expect { create :document, client: client }.to change(client, :last_incoming_interaction_at)
      end

      it "updates client attention_needed_since" do
        expect { create :document, client: client}.to change(client, :attention_needed_since)
      end

      context "without an explicit relationship to client but an intake that has a client id" do
        let(:client) { create :client, intake: create(:intake) }
        it "still should update the associated client" do
          expect { create :document, intake: client.intake }.to change(client, :attention_needed_since)
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
      let(:user) { create :user, vita_partner: vita_partner }
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
end
