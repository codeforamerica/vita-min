# == Schema Information
#
# Table name: efile_submission_transition_errors
#
#  id                             :bigint           not null, primary key
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  dependent_id                   :bigint
#  efile_error_id                 :bigint
#  efile_submission_id            :bigint
#  efile_submission_transition_id :bigint
#
# Indexes
#
#  index_efile_submission_transition_errors_on_dependent_id         (dependent_id)
#  index_efile_submission_transition_errors_on_efile_error_id       (efile_error_id)
#  index_efile_submission_transition_errors_on_efile_submission_id  (efile_submission_id)
#  index_este_on_esti                                               (efile_submission_transition_id)
#
FactoryBot.define do
  factory :efile_submission_transition_error do
    efile_submission_transition
    efile_error
  end
end
