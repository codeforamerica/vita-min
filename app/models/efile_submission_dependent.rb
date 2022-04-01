# == Schema Information
#
# Table name: efile_submission_dependents
#
#  id                  :bigint           not null, primary key
#  age_during_tax_year :integer
#  qualifying_child    :boolean
#  qualifying_ctc      :boolean
#  qualifying_relative :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  dependent_id        :bigint
#  efile_submission_id :bigint
#
# Indexes
#
#  index_efile_submission_dependents_on_dependent_id         (dependent_id)
#  index_efile_submission_dependents_on_efile_submission_id  (efile_submission_id)
#
class EfileSubmissionDependent < ApplicationRecord
  belongs_to :dependent
  belongs_to :efile_submission

  delegate :age, :first_name, :last_name, :ssn, :irs_relationship_enum, :birth_date, :tin_type_ssn?, :tin_type_atin?, to: :dependent

  def self.create_qualifying_dependent(submission, dependent)
    raise "Cannot create EfileSubmissionDependent for dependent not associated with submission's intake" unless submission.intake.dependents.where(id: dependent.id).exists?

    eligibility = Efile::DependentEligibility::Eligibility.new(dependent, submission.tax_year)
    if [eligibility.qualifying_child?, eligibility.qualifying_ctc?, eligibility.qualifying_relative?].any?
      create(
        efile_submission: submission,
        dependent: dependent,
        qualifying_child: eligibility.qualifying_child?,
        qualifying_relative: eligibility.qualifying_relative?,
        qualifying_ctc: eligibility.qualifying_ctc?,
        age_during_tax_year: eligibility.age
      )
    end
  end
end
