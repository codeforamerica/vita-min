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
FactoryBot.define do
  factory :fraud_score, class: Fraud::Score do
    score { 60 }
    snapshot { { "timezone": { points: 60, data: ["Mexico/Tijuana"] } } }
  end
end
