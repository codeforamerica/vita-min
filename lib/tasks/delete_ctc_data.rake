namespace :delete_ctc_data do
  def ctc_intake_2021_drivers_license_records
    DriversLicense.all.select { |x| x.intake_as_primary.class == Archived::Intake::CtcIntake2021 } +
      DriversLicense.all.select { |x| x.intake_as_spouse.class == Archived::Intake::CtcIntake2021 }
  end

  def ctc_intake_drivers_license_records
    DriversLicense.all.select { |x| x.intake_as_primary.class == Intake::CtcIntake } +
      DriversLicense.all.select { |x| x.intake_as_spouse.class == Intake::CtcIntake }
  end

  def ctc_client_records
    Client.all.select { |c| c.intake.class == Intake::CtcIntake }
  end

  def ctc_2021_client_records
    Client.all.select { |c| c.intake.class == Archived::Intake::CtcIntake2021 }
  end

  def ctc_intake_2021_records
    Archived::Intake::CtcIntake2021.all
  end

  def ctc_intake_records
    Intake::CtcIntake.all
  end

  def associated_tax_return_records
    'TODO'
  end

  def tax_return_is_ctc_records
    TaxReturn.where(is_ctc: true)
  end

  task perform: :environment do
    p '--------------------------------'
    p 'STARTING delete_ctc_data:perform'
    p '--------------------------------'

    p 'Continue? Type YES and hit enter: '
    resp = STDIN.gets
    if resp.chomp != "YES"; exit(0); end

    # Destroy all SystemNote::CtcPortalAction
    ActiveRecord::Base.transaction do
      SystemNote::CtcPortalAction.all.each(&:destroy!) 
      p 'Destroyed all CtcPortalAction records.'
    end

    # Destroy all SystemNote::CtcPortalUpdate
    ActiveRecord::Base.transaction do
      SystemNote::CtcPortalUpdate.all.each(&:destroy!)
      p 'Destroyed all CtcPortalUpdate records.'
    end  

    # Destroy all CtcSignup records.
    ActiveRecord::Base.transaction do
      CtcSignup.all.each(&:destroy!)
      p 'Destroyed all CtcSignup records.'
    end

    # Destroy all Signup records.
    ActiveRecord::Base.transaction do
      Signup.all.each(&:destroy!)
      p 'Destroyed all Signup records.'
    end

    # Destroy all EfileError rcds (could find a way to do just CTC, but simpler to delete them all).
    ActiveRecord::Base.transaction do
      EfileError.all.each(&:destroy!)
      p 'Destroyed all EfileError records.'
    end

    p '--------------------------------'
    # Destroy CTCIntake2021-related DriversLicense records.
    ActiveRecord::Base.transaction do
      p 'Tally of CtcIntake2021-related DriversLicense records BEFORE: ' + ctc_intake_2021_drivers_license_records.count.to_s
      ctc_intake_2021_drivers_license_records.each(&:destroy!)
      p 'Tally of CtcIntake2021-related DriversLicense records AFTER: ' + ctc_intake_2021_drivers_license_records.count.to_s
    end

    p '--------------------------------'
    # Destroy CtcIntake-related DriversLicense records.
    ActiveRecord::Base.transaction do
      p 'Tally of CtcIntake-related DriversLicense records BEFORE: ' + ctc_intake_drivers_license_records.count.to_s
      ctc_intake_drivers_license_records.each(&:destroy!)
      p 'Tally CtcIntake-related DriversLicense records AFTER: ' + ctc_intake_drivers_license_records.count.to_s
    end

    p '--------------------------------'
    # Destroy all Client records have CtcIntake2021-specific intakes.
    # This should destroy associated intake, tax_returns, efile_submissions, documents and has_one_attached items.
    ActiveRecord::Base.transaction do
      p 'Tally of Client records associated w/ CtcIntake2021 record BEFORE: ' + ctc_2021_client_records.count.to_s
      p 'Tally of CtcIntake2021 records BEFORE: ' + ctc_intake_2021_records.count
      # p 'Tally of related TaxReturn records BEFORE: ' +

      # TODO fill out

      p 'Tally of Client records associated w/ CtcIntake2021 record AFTER: ' + ctc_2021_client_records.count.to_s
      p 'Tally of CtcIntake2021 records BEFORE: ' + ctc_intake_2021_records.count
      # p 'Tally of related TaxReturn records BEFORE: ' +
    end

    p '--------------------------------'
    # Destroy client records having CtcIntake-specific intakes.
    # This should destroy associated intake, tax_returns, efile_submissions, documents, and has_one_attached items.
    ActiveRecord::Base.transaction do
      p 'Tally of Client records associated w/ CtcIntake record BEFORE: ' + ctc_client_records.count.to_s

      # TODO fill out

      p 'Tally of Client records associated w/ CtcIntake record AFTER: ' + ctc_client_records.count.to_s
    end

    p '--------------------------------'
    p 'FINISHED delete_ctc_data:perform'
    p '--------------------------------'
  end
end
