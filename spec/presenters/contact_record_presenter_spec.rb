require "rails_helper"

RSpec.describe ContactRecordPresenter do
  context "#message_heading" do
    describe "incoming text message" do
      let(:input_number) { "+15005550006" }

      let(:incoming_text_message) { build :incoming_text_message, from_phone_number: input_number }
      it "sets appropriate heading " do
        expect(ContactRecordPresenter.new(incoming_text_message).message_heading).to eq "from (500) 555-0006"
      end
    end

    describe "outgoing text message" do
      let(:input_number) { "+15005550006" }

      describe "with a user set" do
        let(:outgoing_text_message) { build :outgoing_text_message, to_phone_number: input_number }
        it "sets appropriate heading " do
          expect(ContactRecordPresenter.new(outgoing_text_message).message_heading).to eq "to (500) 555-0006"
        end
      end
    end

    describe "outgoing email" do
      let(:to) { "example@example.com" }
      describe "with a user set" do
        let(:outgoing_email) { build :outgoing_email, to: to }
        it "sets appropriate heading " do
          expect(ContactRecordPresenter.new(outgoing_email).message_heading).to eq "to example@example.com"
        end
      end
    end

    describe 'incoming email' do
      let(:incoming_email) { create :incoming_email, from: "example@example.com" }
      it "should return the email heading" do
        expect(ContactRecordPresenter.new(incoming_email).message_heading).to eq "from example@example.com"
      end
    end
  end
end
