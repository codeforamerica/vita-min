# == Schema Information
#
# Table name: fraud_scores
#
#  id                  :bigint           not null, primary key
#  score               :integer
#  snapshot            :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  efile_submission_id :bigint
#
# Indexes
#
#  index_fraud_scores_on_efile_submission_id  (efile_submission_id)
#
require "rails_helper"

describe Fraud::Score do
  describe '#create_from' do
    let(:submission) { create :efile_submission }
    let!(:fraud_indicator) { create :duplicate_fraud_indicator }
    context "" do
      before do
        allow_any_instance_of(Fraud::Indicator).to receive(:execute)
      end

      context "when there are some FraudIndicators to execute" do
        let!(:fraud_indicator) { create :duplicate_fraud_indicator, name: "first_indicator" }
        let!(:second_fraud_indicator) { create :duplicate_fraud_indicator, name: "second_indicator" }
        before do
          allow(Fraud::Indicator).to receive(:all).and_return([fraud_indicator, second_fraud_indicator])
          allow_any_instance_of(Fraud::Indicator).to receive(:execute).and_return([60, [1, 2, 3]])
        end

        it "passes the relevant data to the FraudIndicator calculation and creates a fraud score object" do
          expect {
            described_class.create_from(submission)
          }.to change(Fraud::Score, :count).by 1
          expect(fraud_indicator).to have_received(:execute).with({
                                                                      client: submission.client,
                                                                      efile_submission: submission,
                                                                      bank_account: submission.intake.bank_account,
                                                                      intake: submission.intake,
                                                                      tax_return: submission.tax_return
                                                                  })
          object = Fraud::Score.last
          expect(object.score).to eq 120
          expect(object.snapshot).to eq ({ "first_indicator" => { "points" => 60, "data" => [1,2,3] }, "second_indicator" => { "points" => 60, "data" => [1,2,3] } })
        end
      end
    end
  end
end
