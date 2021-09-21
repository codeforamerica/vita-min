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

  describe "#admin_resubmission?" do
    context "when it is the only submission for the client" do
      context "when there has been a previous transition to resubmitted" do
        before do
          submission.transition_to(:queued)
          submission.transition_to(:failed)
        end

        context "and it was resubmitted by a user" do
          before do
            submission.transition_to!(:resubmitted, initiated_by_id: user.id)
          end

          it "is true" do
            expect(FraudIndicatorService.new(submission).admin_resubmission?).to eq true
          end
        end

        context "and it was not resubmitted by a user" do
          before do
            submission.transition_to!(:resubmitted)
          end

          it "is false" do
            expect(FraudIndicatorService.new(submission).admin_resubmission?).to eq false
          end
        end
      end

      context "when there has not been a previous transition to resubmitted" do
        it "is falsey" do
          expect(FraudIndicatorService.new(submission).admin_resubmission?).to eq nil
        end
      end
    end

    context "when the client has more than one submission" do
      context "when the previous submission was resubmitted" do

        context "when the resubmission was by a user" do
          before do
            og_submission = EfileSubmission.create(client: submission.client, tax_return: submission.tax_return)
            og_submission.transition_to(:preparing)
            og_submission.transition_to(:failed)
            og_submission.transition_to(:resubmitted, initiated_by_id: user.id)
            allow(submission).to receive(:previously_transmitted_submission).and_return og_submission
          end
          it "is true" do
            expect(FraudIndicatorService.new(submission).admin_resubmission?).to eq true
          end
        end

        context "when the resubmission was not by a user" do
          before do
            og_submission = EfileSubmission.create(client: submission.client, tax_return: submission.tax_return)
            og_submission.transition_to(:preparing)
            og_submission.transition_to(:failed)
            og_submission.transition_to(:resubmitted, initiated_by_id: nil)
            allow(submission).to receive(:previously_transmitted_submission).and_return og_submission
          end

          it "is false" do
            expect(FraudIndicatorService.new(submission).admin_resubmission?).to eq false
          end
        end
      end
    end
  end
end