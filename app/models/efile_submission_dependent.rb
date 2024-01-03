# == Schema Information
#
# Table name: efile_submission_dependents
#
#  id                  :bigint           not null, primary key
#  age_during_tax_year :integer
#  qualifying_child    :boolean
#  qualifying_ctc      :boolean
#  qualifying_eitc     :boolean
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
  belongs_to :dependent, -> { with_deleted }
  belongs_to :efile_submission
  has_one :intake, through: :efile_submission

  delegate :first_name, :last_name, :full_name, :ssn, :irs_relationship_enum, :birth_date, :tin_type_ssn?, :tin_type_atin?, :ip_pin, :full_time_student_yes?, :permanently_totally_disabled_yes?, :months_in_home, to: :dependent

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
        qualifying_eitc: eligibility.qualifying_eitc?,
        age_during_tax_year: eligibility.age
      )
    end
  end

  def skip_schedule_eic_question_4?
    younger_than_filers && age_during_tax_year < 19
  end

  def schedule_eic_4a?
    return false if skip_schedule_eic_question_4?
    full_time_student_yes? && age_during_tax_year < 24 && younger_than_filers
  end

  def schedule_eic_4b?
    return unless schedule_eic_4a? == false

    permanently_totally_disabled_yes?
  end

  def younger_than_filers
    intake.filers.any? { |filer| birth_date > filer.birth_date }
  end
end
