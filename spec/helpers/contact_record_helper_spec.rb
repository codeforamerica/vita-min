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

    describe "#mailgun_deliverability_status" do
      context "when the status is nil" do
        it "returns nil" do
          expect(helper.mailgun_deliverability_status(nil)).to eq nil
        end
      end

      context "when status is not nil" do
        context "when the mailgun_status is delivered" do
          let(:mailgun_status) { "delivered" }
          let(:image_tag) { helper.image_tag("icons/check.svg", alt: mailgun_status, title: mailgun_status, class: 'message__status') }
          it "returns the correct image tag" do
            expect(helper.mailgun_deliverability_status(mailgun_status)).to eq image_tag
          end
        end

        context "when the mailgun_status is permanent_fail" do
          let(:mailgun_status) { "permanent_fail" }
          let(:image_tag) { helper.image_tag("icons/exclamation.svg", alt: mailgun_status, title: mailgun_status, class: 'message__status') }
          it "returns the correct image tag" do
            expect(helper.mailgun_deliverability_status(mailgun_status)).to eq image_tag
          end
        end
      end
    end
  end
end