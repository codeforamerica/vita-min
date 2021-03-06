# == Schema Information
#
# Table name: efile_submissions
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  irs_submission_id :string
#  tax_return_id     :bigint
#
# Indexes
#
#  index_efile_submissions_on_tax_return_id  (tax_return_id)
#
FactoryBot.define do
  factory :efile_submission do
    tax_return

    trait :ctc do
      transient do
        tax_year { 2020 }
        filing_status { "single" }
      end
      tax_return { create(:tax_return, :ctc, year: tax_year, filing_status: filing_status) }
      after :create do |submission|
        create :address, record: submission
      end
    end

    EfileSubmissionStateMachine.states.each do |state|
      trait state.to_sym do
        after :create do |submission|
          create :efile_submission_transition, state, efile_submission: submission
        end
      end
    end
  end
end
