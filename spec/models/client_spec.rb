# == Schema Information
#
# Table name: clients
#
#  id                           :bigint           not null, primary key
#  email_address                :string
#  last_incoming_interaction_at :datetime
#  last_interaction_at          :datetime
#  phone_number                 :string
#  preferred_name               :string
#  response_needed_since        :datetime
#  sms_phone_number             :string
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
        expect(client.needs_response?).to eq false
      end
    end

    context "when client has a new document" do
      let!(:client) { create :client }
      before { create :document, client: client }

      it "needs attention" do
        expect(client.needs_response?).to eq true
      end
    end

    context "when clients intake was completed" do
      let!(:client) { create :client, intakes: [create(:intake)] }

      it "needs attention" do
        client.intake.update(completed_at: Time.now)
        expect(client.needs_response?).to eq true
      end
    end

    context "when client has a new incoming text message" do
      let!(:client) { create :client }
      before { create :incoming_text_message, client: client }

      it "needs attention" do
        expect(client.needs_response?).to eq true
      end
    end

    context "when client has a new incoming email" do
      let!(:client) { create :client }
      before { create :incoming_email, client: client }

      it "needs attention" do
        expect(client.needs_response?).to eq true
      end
    end

    context "when client has a new outgoing email" do
      let!(:client) { create :client }
      before { create :outgoing_email, client: client }

      it "doesn't need attention" do
        expect(client.needs_response?).to eq false
      end
    end

    context "when client has a new outgoing text" do
      let!(:client) { create :client }
      before { create :outgoing_email, client: client }

      it "doesn't need attention" do
        expect(client.needs_response?).to eq false
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

      it "updates client#last_interaction_at" do
        expect { create :outgoing_email, client: client }.to change(client, :last_interaction_at)
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

      it "updates client #last_interaction_at" do
        expect { create :outgoing_text_message, client: client }.to change(client, :last_interaction_at)
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

      it "updates client last_interaction_at" do
        expect { create :note, client: client }.to change(client, :last_interaction_at)
      end

      it "does not update the response_needed_since" do
        expect { create :note, client: client }.not_to change(client, :response_needed_since)
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

      it "updates client response_needed_since" do
        expect { create :document, client: client}.to change(client, :response_needed_since)
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
end
