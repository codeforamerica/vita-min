require "rails_helper"

describe FraudIndicatorService do
  let(:submission) { create :efile_submission, :preparing }
  let(:user) { create :admin_user }
  describe "#assess!" do
    context "when a recaptcha score is fraudy" do
      before do
        create :efile_security_information, client: submission.client, recaptcha_score: 0.1
      end

      it "transitions the status to on hold" do
        expect {
          FraudIndicatorService.new(submission).assess!
        }.to change(submission, :current_state).from("preparing").to("fraud_hold")
      end

      it "returns true" do
        expect(FraudIndicatorService.new(submission).assess!).to eq true
      end
    end

    context "when recaptcha scores are not present" do
      before do
        create :efile_security_information, client: submission.client, recaptcha_score: nil
      end

      it "does not transition to on hold" do
        expect {
          FraudIndicatorService.new(submission).assess!
        }.not_to change(submission, :current_state).from("preparing")
      end

      it "returns false" do
        expect(FraudIndicatorService.new(submission).assess!).to eq false
      end
    end

    context "when recaptcha score is present but above the fraud threshold" do
      before do
        create :efile_security_information, client: submission.client, recaptcha_score: 0.6
      end

      it "does not transition to on hold" do
        expect {
          FraudIndicatorService.new(submission).assess!
        }.not_to change(submission, :current_state).from("preparing")
      end
    end
  end
end