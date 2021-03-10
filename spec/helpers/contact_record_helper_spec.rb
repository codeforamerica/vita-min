require 'rails_helper'

describe ContactRecordHelper do
  context "#message_heading" do
    describe "incoming text message" do
      let(:input_number) { "+15005550006" }

      let(:incoming_text_message) { build :incoming_text_message, from_phone_number: input_number }
      it "sets appropriate heading " do
        expect(helper.message_heading(incoming_text_message)).to eq "from (500) 555-0006"
      end
    end

    describe "outgoing text message" do
      let(:input_number) { "+15005550006" }

      describe "with a user set" do
        let(:outgoing_text_message) { build :outgoing_text_message, to_phone_number: input_number }
        it "sets appropriate heading " do
          expect(helper.message_heading(outgoing_text_message)).to eq "to (500) 555-0006"
        end
      end
    end

    describe "outgoing email" do
      let(:to) { "example@example.com" }
      describe "with a user set" do
        let(:outgoing_email) { build :outgoing_email, to: to }
        it "sets appropriate heading " do
          expect(helper.message_heading(outgoing_email)).to eq "to example@example.com"
        end
      end
    end

    describe 'incoming email' do
      let(:incoming_email) { create :incoming_email, from: "example@example.com" }
      it "should return the email heading" do
        expect(helper.message_heading(incoming_email)).to eq "from example@example.com"
      end
    end
  end
end