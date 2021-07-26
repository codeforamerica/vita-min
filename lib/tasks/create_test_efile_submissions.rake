namespace :efile do
  desc "Create sample e-file submission data"
  task :seed_submissions, [:count] => :environment do |_task, args|
    submissions = FactoryBot.create_list :efile_submission, 100, :ctc

    preparing_group = submissions.take(95)
    preparing_group.each do |submission|
      submission.transition_to!(:preparing)
    end

    queued_group = preparing_group.take(75)
    queued_group.each do |submission|
      submission.transition_to!(:queued)
    end

    failed = queued_group.last(10)
    failed.each do |submission|
      submission.transition_to!(:failed, {
        error_code: "TransmissionError",
        error_message: "Some response from the service indicating that the IRS e-file service is temporarily down."
      })
    end

    transmitted_group = queued_group.first(45)
    transmitted_group.each do |submission|
      submission.transition_to!(:transmitted)
    end

    accepted_group = transmitted_group.first(10)
    accepted_group.each do |submission|
      submission.transition_to!(:accepted)
    end

    rejected_group = transmitted_group.last(25)
    errors = {
        "SH-F1040-012-02": "If Schedule H (Form 1040), 'TotalTaxHouseholdEmplCalcAmt' has a non-zero value, then it must be equal to 'TotSSMedcrFedITAftrNrfdblCrAmt'.",
        "IND-563": "For each dependent in the return with 'EligibleForChildTaxCreditInd' checked, the corresponding 'DependentSSN' must not be the same as a Dependent SSN on another return.",
        "IND-931-01": "The Dependent SSN (or Qualifying Child Identifying Number on Form 1040-SS (PR)) has been locked because Social Security Administration records indicate the number belongs to a deceased individual.",
        "R0000-500-01": "'PrimarySSN' and 'PrimaryNameControlTxt' in the Return Header must match the e-File database.",
        "R0000-503-02": "Spouse SSN and Spouse Name Control in the return must match the e-File database.",
        "R0000-504-02": "Each 'DependentSSN' and the corresponding 'DependentNameControlTxt' that has a value in 'DependentDetail' in the return must match the SSN and Name Control in the e-File database."
    }
    rejected_group.each do |submission|
      error_key = errors.keys.sample
      submission.transition_to!(:rejected, { error_code: error_key, error_message: errors[error_key] })
    end
  end
end
