require "rails_helper"

describe NotReadyReminder do
  context '.process' do
    context "when the intake status was not intake in progress" do
      let(:tax_return) { create :tax_return, :file_accepted }
      it "returns nil" do
        expect(described_class.process(tax_return)).to be_nil
      end
    end

    context "when the intake has not been updated in more than 9 days" do
      let(:tax_return) { create :tax_return, :intake_in_progress, updated_at: 10.days.ago }
      it "returns changed_status and updates the status to file_not_filing" do
        expect {
          response = described_class.process(tax_return)
          expect(response).to eq "changed_status"
        }.to change(SystemNote::NotReadyNotFilingTransition, :count).by 1
        expect(SystemNote::NotReadyNotFilingTransition.last.client).to eq tax_return.client
        expect(tax_return.reload.state).to eq "file_not_filing"
      end
    end

    context "when the intake has not been updated in more than 6 days, less than 9" do
      let(:tax_return) { create :tax_return, :intake_in_progress, updated_at: 7.days.ago }
      let(:automated_message_double) { double }

      before do
        allow(SendAutomatedMessage).to receive(:new).with(client: tax_return.client,
                                                          message: AutomatedMessage::SecondNotReadyReminder
        ).and_return(automated_message_double)
        allow(automated_message_double).to receive(:send_messages)
      end

      context "when the not ready message has already been sent" do
        before do

          MessageTracker.new(client: tax_return.client, message: AutomatedMessage::SecondNotReadyReminder).record(DateTime.current)
        end

        it "does not send a message, responds with nil" do
          expect(MessageTracker.new(client: tax_return.client, message: AutomatedMessage::SecondNotReadyReminder).already_sent?).to eq true
          response = described_class.process(tax_return)
          expect(response).to eq nil
          expect(SendAutomatedMessage).not_to have_received(:new)
        end
      end

      context "when the not ready message hasnt been sent" do
        it "sends a message, responds with second reminder key" do
          response = described_class.process(tax_return)
          expect(response).to eq "messages.not_ready_second_reminder"
          expect(automated_message_double).to have_received(:send_messages)
        end
      end
    end

    context "when the intake has not been updated in more than 3 days, less than 6" do
      let(:tax_return) { create :tax_return, :intake_in_progress, updated_at: 4.days.ago }
      let(:automated_message_double) { double }

      before do
        allow(SendAutomatedMessage).to receive(:new).with(client: tax_return.client,
                                                          message: AutomatedMessage::FirstNotReadyReminder
        ).and_return(automated_message_double)
        allow(automated_message_double).to receive(:send_messages)
      end

      context "when the not ready message has already been sent" do
        before do
          MessageTracker.new(client: tax_return.client, message: AutomatedMessage::FirstNotReadyReminder).record(DateTime.current)
        end

        it "does not send a message, responds with nil" do
          expect(MessageTracker.new(client: tax_return.client, message: AutomatedMessage::FirstNotReadyReminder).already_sent?).to eq true
          response = described_class.process(tax_return)
          expect(response).to eq nil
          expect(SendAutomatedMessage).not_to have_received(:new)
        end
      end

      context "when the not ready message hasnt been sent" do
        it "sends a message, responds with first reminder key" do
          response = described_class.process(tax_return)
          expect(response).to eq "messages.not_ready_first_reminder"
          expect(automated_message_double).to have_received(:send_messages)
        end
      end
    end


    context "when the intake was updated recently" do
      let(:tax_return) { create :tax_return, :intake_in_progress, updated_at: 1.day.ago }
      it "returns nil" do
        expect(described_class.process(tax_return)).to be_nil
      end
    end
  end
end