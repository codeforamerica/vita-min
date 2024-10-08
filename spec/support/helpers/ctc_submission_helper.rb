module CtcSubmissionHelper
  def create_qualifying_dependents(submission)
    submission.qualifying_dependents.delete_all
    submission.intake.dependents.each do |dependent|
      EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
    end
  end
end