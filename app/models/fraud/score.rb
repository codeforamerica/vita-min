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
module Fraud
  class Score < ApplicationRecord
    self.table_name = "fraud_scores"
    HOLD_THRESHOLD = 50
    RESTRICT_THRESHOLD = 100

    belongs_to :efile_submission

    def self.create_from(submission)
      snapshot = Fraud::Indicator.all.map do |indicator|
        points, data = indicator.execute(
          client: submission.client,
          efile_submission: submission,
          tax_return: submission.tax_return,
          bank_account: submission.intake.bank_account,
          intake: submission.intake
        )
        [indicator.name, { points: points, data: data }]
      end.to_h

      score = snapshot.values.map { |v| v[:points] }.sum
      create(efile_submission: submission, snapshot: snapshot, score: score)
    end
  end
end
