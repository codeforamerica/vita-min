# == Schema Information
#
# Table name: fraud_scores
#
#  id                  :bigint           not null, primary key
#  indicators          :jsonb
#  score               :integer
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

    belongs_to :efile_submission

    def self.create_from(submission)
      indicators = Fraud::Indicator.all.map do |indicator|
        points, data = indicator.execute(
          client: submission.client,
          efile_submission: submission,
          tax_return: submission.tax_return,
          bank_account: submission.intake.bank_account,
          intake: submission.intake
        )
        [indicator.name, { points: points, data: data }]
      end.to_h

      score = indicators.values.map { |v| v[:points] }.sum
      create(efile_submission: submission, indicators: indicators, score: score)
    end
  end
end
