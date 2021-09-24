require "rails_helper"

describe FraudIndicatorService do
  let(:submission) { create :efile_submission, :preparing }
  let(:user) { create :admin_user }

  describe "#hold_indicators" do
    context "recaptcha_score" do
      context "when a recaptcha score is fraudy" do
        before do
          create :efile_security_information, client: submission.client, recaptcha_score: 0.1
        end

        it "responds with an array that includes recaptcha_score" do
          expect(FraudIndicatorService.new(submission).hold_indicators).to eq ['recaptcha_score']
        end
      end

      context "when recaptcha scores are not present" do
        before do
          create :efile_security_information, client: submission.client, recaptcha_score: nil
        end

        it "the response array does not include recaptcha_score" do
          expect(FraudIndicatorService.new(submission).hold_indicators).to eq []
        end
      end

      context "when recaptcha score is present but above the fraud threshold" do
        before do
          create :efile_security_information, client: submission.client, recaptcha_score: 0.6
        end

        it "the response array does not include recaptcha_score" do
          expect(FraudIndicatorService.new(submission).hold_indicators).to eq []
        end
      end
    end
  end
end