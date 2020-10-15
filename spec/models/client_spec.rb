require "rails_helper"

describe Client do
  describe "touch behavior" do
    let!(:client) { create :client }

    describe "incoming text message" do
      it "updates client updated_at" do
        expect { create :incoming_text_message, client: client }.to change(client, :updated_at)
      end
    end

    describe "incoming email" do
      it "updates client updated_at" do
        expect { create :incoming_email, client: client }.to change(client, :updated_at)
      end
    end

    describe "outgoing email" do
      it "updates client updated_at" do
        expect { create :outgoing_email, client: client }.to change(client, :updated_at)
      end
    end

    describe "outgoing text" do
      it "updates client updated_at" do
        expect { create :outgoing_text_message, client: client }.to change(client, :updated_at)
      end
    end

    describe "note" do
      it "updates client updated_at" do
        expect { create :note, client: client }.to change(client, :updated_at)
      end
    end

    describe "document" do
      it "updates client updated_at" do
        expect { create :document, client: client }.to change(client, :updated_at)
      end
    end

    describe "intake" do
      it "updates when the intake changes" do
        intake = create :intake, client: client
        expect { intake.update(needs_help_2019: "yes") }.to change(client, :updated_at)
      end
    end
  end
end