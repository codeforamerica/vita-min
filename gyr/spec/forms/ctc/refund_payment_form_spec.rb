require "rails_helper"

describe Ctc::RefundPaymentForm do
  let(:intake) { create :ctc_intake }
  context "validations" do
    it "requires refund_payment_method" do
      form = described_class.new(intake, {})
      expect(form).not_to be_valid
    end
  end

  describe "#save" do
    it "persists the refund payment value to the intake" do
      expect {
        described_class.new(intake, { refund_payment_method: "check" }).save
      }.to change(intake, :refund_payment_method).from("unfilled").to("check")
    end
  end
end