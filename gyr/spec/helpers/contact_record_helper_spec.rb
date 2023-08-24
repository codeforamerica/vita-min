require 'rails_helper'

describe ContactRecordHelper do
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
