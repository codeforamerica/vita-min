# Can run manually via:
#     bundle exec rake delete_ctc_data:perform
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

  def tax_return_is_ctc_records
    TaxReturn.where(is_ctc: true)
  end

  def get_drivers_license_ids_for_ctc_intakes
    ids = Set[]
    ctc_intake_2021_records.each do |intake|
      ids.add(intake.primary_drivers_license_id) if intake.primary_drivers_license_id.present?
      ids.add(intake.spouse_drivers_license_id) if intake.spouse_drivers_license_id.present?
    end
    ctc_intake_records.each do |intake|
      ids.add(intake.primary_drivers_license_id) if intake.primary_drivers_license_id.present?
      ids.add(intake.spouse_drivers_license_id) if intake.spouse_drivers_license_id.present?
    end
    ids
  end

  task perform: :environment do
    p '--------------------------------'
    p 'STARTING delete_ctc_data:perform'
    p '--------------------------------'

    p 'Continue? Type YES and hit enter: '
    resp = STDIN.gets
    if resp.chomp != "YES"; exit(0); end

    # Save DriversLicense IDs as a preliminary step; then we'll destroy the
    # DriversLicense records at the end. (A PG::ForeignKeyViolation error
    # occurs if attempting to destroy a DriversLicense record when an existing Intake
    # record has a `primary_drivers_license_id` or `spouse_drivers_license_id`
    # referring to the DriversLicense record in question.)
    saved_ctc_drivers_license_ids = get_drivers_license_ids_for_ctc_intakes

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

    # Destroy CTC EfileError rcds.
    ActiveRecord::Base.transaction do
      EfileError.where(service_type: :ctc).each(&:destroy!)
      p 'Destroyed CTC EfileError records.'
    end

    p '--------------------------------'
    # Destroy all Client records have CtcIntake2021-specific intakes.
    # This should destroy associated intake, tax_returns, efile_submissions, documents and has_one_attached items.
    ActiveRecord::Base.transaction do
      p 'Client records (and associated) 1/2 ...'
      p 'Tally of Client records associated w/ CtcIntake2021 record BEFORE: ' + ctc_2021_client_records.count.to_s
      p 'Tally of CtcIntake2021 records BEFORE: ' + ctc_intake_2021_records.count.to_s
      p 'Tally of all TaxReturn records BEFORE: ' + TaxReturn.all.count.to_s

      ctc_2021_client_records.each(&:destroy!)

      p 'Tally of Client records associated w/ CtcIntake2021 record AFTER: ' + ctc_2021_client_records.count.to_s
      p 'Tally of CtcIntake2021 records AFTER: ' + ctc_intake_2021_records.count.to_s
      p 'Tally of all TaxReturn records AFTER: ' + TaxReturn.all.count.to_s
    end

    p '--------------------------------'
    # Destroy client records having CtcIntake-specific intakes.
    # This should destroy associated intake, tax_returns, efile_submissions, documents, and has_one_attached items.
    ActiveRecord::Base.transaction do
      p 'Client records (and associated) 2/2 ...'
      p 'Tally of Client records associated w/ CtcIntake record BEFORE: ' + ctc_client_records.count.to_s
      p 'Tally of CtcIntake records BEFORE: ' + ctc_intake_records.count.to_s
      p 'Tally of all TaxReturn records BEFORE: ' + TaxReturn.all.count.to_s

      ctc_client_records.each(&:destroy!)

      p 'Tally of Client records associated w/ CtcIntake record AFTER: ' + ctc_client_records.count.to_s
      p 'Tally of CtcIntake records AFTER: ' + ctc_intake_records.count.to_s
      p 'Tally of all TaxReturn records AFTER: ' + TaxReturn.all.count.to_s
    end

    p '--------------------------------'
    # Destroy any remaining TaxReturn records where is_ctc is true (if any). (It's not clear
    # if the `is_ctc` flag is/was being used consistently, at least based on the data
    # in seeder.rb; hence this extra step just for thoroughness.)
    ActiveRecord::Base.transaction do
      p 'Remaining TaxRecords (if any) where `is_ctc` is true'
      p 'Tally BEFORE: ' + tax_return_is_ctc_records.count.to_s

      tax_return_is_ctc_records.each(&:destroy!)

      p 'Tally AFTER: ' + tax_return_is_ctc_records.count.to_s
    end

    p '--------------------------------'
    # Destroy CTC-related DriversLicense records.
    ActiveRecord::Base.transaction do
      p 'CTC DriversLicense records ...'
      p 'Tally of CtcIntake2021-related DriversLicense records BEFORE: ' + ctc_intake_2021_drivers_license_records.count.to_s
      p 'Tally of CtcIntake-related DriversLicense records BEFORE: ' + ctc_intake_drivers_license_records.count.to_s

      # These IDs were saved at the beginning of the script.
      saved_ctc_drivers_license_ids.each { |id| DriversLicense.find(id).destroy! }

      p 'Tally of CtcIntake2021-related DriversLicense records AFTER: ' + ctc_intake_2021_drivers_license_records.count.to_s
      p 'Tally CtcIntake-related DriversLicense records AFTER: ' + ctc_intake_drivers_license_records.count.to_s
    end

    p '--------------------------------'
    p 'FINISHED delete_ctc_data:perform'
    p '--------------------------------'
  end
end
