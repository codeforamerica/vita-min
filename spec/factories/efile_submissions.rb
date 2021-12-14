# == Schema Information
#
# Table name: efile_submissions
#
#  id                      :bigint           not null, primary key
#  last_checked_for_ack_at :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  irs_submission_id       :string
#  tax_return_id           :bigint
#
# Indexes
#
#  index_efile_submissions_on_created_at            (created_at)
#  index_efile_submissions_on_irs_submission_id     (irs_submission_id)
#  index_efile_submissions_on_tax_return_id         (tax_return_id)
#  index_efile_submissions_on_tax_return_id_and_id  (tax_return_id,id DESC)
#
FactoryBot.define do
  factory :efile_submission do
    transient do
      tax_year { TaxReturn.current_tax_year }
      filing_status { "single" }
      metadata { {} }
    end
    tax_return { create :tax_return, :ctc, year: tax_year, filing_status: filing_status }

    trait :ctc do
      after :create do |submission|
        create :address, record: submission
      end
    end


    EfileSubmissionStateMachine.states.each do |state|
      trait state.to_sym do
        after :create do |submission, evaluator|
          create :efile_submission_transition, state, efile_submission: submission, metadata: evaluator.metadata
        end
      end
    end

    trait :with_errors do
      after :create do |submission|
        raw_xml = File.read(File.join(Rails.root, "spec/fixtures/files", "irs_acknowledgement_rejection.xml"))
        submission.efile_submission_transitions.last.update(metadata: { raw_response: raw_xml })
        Efile::SubmissionErrorParser.persist_errors(submission.efile_submission_transitions.last)
      end
    end
  end
end
