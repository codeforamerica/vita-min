# == Schema Information
#
# Table name: efile_submission_transitions
#
#  id                  :bigint           not null, primary key
#  metadata            :jsonb
#  most_recent         :boolean          not null
#  sort_key            :integer          not null
#  to_state            :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  efile_submission_id :integer          not null
#
# Indexes
#
#  index_efile_submission_transitions_parent_most_recent  (efile_submission_id,most_recent) UNIQUE WHERE most_recent
#  index_efile_submission_transitions_parent_sort         (efile_submission_id,sort_key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (efile_submission_id => efile_submissions.id)
#
FactoryBot.define do
  factory :efile_submission_transition do
    efile_submission
    
    EfileSubmissionStateMachine.states.each do |state|
      trait state.to_sym do
        to_state { state }
        sort_key { 0 }
        most_recent { true }
      end
    end
  end
end
