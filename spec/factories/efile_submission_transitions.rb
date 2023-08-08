# == Schema Information
#
# Table name: efile_submission_transitions
#
#  id                    :bigint           not null, primary key
#  efile_submission_type :string           default("EfileSubmission"), not null
#  metadata              :jsonb
#  most_recent           :boolean          not null
#  sort_key              :integer          not null
#  to_state              :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  efile_submission_id   :integer          not null
#
# Indexes
#
#  index_efile_sub_transitions_on_efile_sub_type_and_efile_sub_id  (efile_submission_type,efile_submission_id)
#  index_efile_submission_transitions_on_created_at                (created_at)
#  index_efile_submission_transitions_parent_most_recent           (efile_submission_id,most_recent) UNIQUE WHERE most_recent
#  index_efile_submission_transitions_parent_sort                  (efile_submission_id,sort_key) UNIQUE
#
FactoryBot.define do
  factory :efile_submission_transition do
    efile_submission
    most_recent { true }
    sort_key { 0 }
    to_state { "preparing" }
    EfileSubmissionStateMachine.states.each do |state|
      trait state.to_sym do
        to_state { state }
      end
    end
  end
end
