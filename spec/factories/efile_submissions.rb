# == Schema Information
#
# Table name: efile_submissions
#
#  id            :bigint           not null, primary key
#  tax_return_id :bigint
#
# Indexes
#
#  index_efile_submissions_on_tax_return_id  (tax_return_id)
#
FactoryBot.define do
  factory :efile_submission do
    tax_return

    EfileSubmissionStateMachine.states.each do |state|
      trait state.to_sym do
        after(:create) do |submission|
          FactoryGirl.create(:efile_submission_transition, state, efile_submission: submission)
        end
      end
    end
  end
end
