# Can run manually via:
#     bundle exec rake delete_ctc_data:perform[mode]
#     ... where mode is DRY_RUN or DESTRUCTIVE
namespace :delete_ctc_data do
  def get_drivers_license_ids_for_ctc_intakes
    ids = Set[]
    Intake::CtcIntake.find_each do |intake|
      ids.add(intake.primary_drivers_license_id) if intake.primary_drivers_license_id.present?
      ids.add(intake.spouse_drivers_license_id) if intake.spouse_drivers_license_id.present?
    end
    ids
  end

  def drivers_license_tally(ids)
    DriversLicense.where(id: ids).size
  end

  task :perform, [:mode] => :environment do |_task, args|
    p '--------------------------------'
    p 'STARTING delete_ctc_data:perform'
    p '--------------------------------'

    if ! ['DRY_RUN', 'DESTRUCTIVE'].include? args.mode
      p 'Specify mode, either DRY_RUN or DESTRUCTIVE'
      return
    end

    DRY_RUN = true if args.mode != 'DESTRUCTIVE'
    if DRY_RUN
      p 'DRY RUN! Nothing will be deleted.'
    end

    p 'Continue? Type YES and hit enter: '
    resp = STDIN.gets
    if resp.chomp != "YES"; exit(0); end

    #---------------------------------------------------------------------------
    #  prep
    #---------------------------------------------------------------------------

    # Save DriversLicense IDs as a preliminary step; then we'll destroy the
    # DriversLicense records later. (A PG::ForeignKeyViolation error
    # occurs if attempting to destroy a DriversLicense record when an existing Intake
    # record has a `primary_drivers_license_id` or `spouse_drivers_license_id`
    # referring to the DriversLicense record in question.)
    saved_ctc_drivers_license_ids = get_drivers_license_ids_for_ctc_intakes

    #---------------------------------------------------------------------------
    #  general stuff
    #---------------------------------------------------------------------------

    p '--------------------------------'
    # Destroy all SystemNote::CtcPortalAction
    ActiveRecord::Base.transaction do
      SystemNote::CtcPortalAction.all.each(&:destroy!) 
      p 'Destroyed all CtcPortalAction records.'

      raise ActiveRecord::Rollback if DRY_RUN
    end

    p '--------------------------------'
    # Destroy all SystemNote::CtcPortalUpdate
    ActiveRecord::Base.transaction do
      SystemNote::CtcPortalUpdate.all.each(&:destroy!)
      p 'Destroyed all CtcPortalUpdate records.'

      raise ActiveRecord::Rollback if DRY_RUN
    end  

    p '--------------------------------'
    # Destroy all CtcSignup records.
    ActiveRecord::Base.transaction do
      CtcSignup.all.each(&:destroy!)
      p 'Destroyed all CtcSignup records.'

      raise ActiveRecord::Rollback if DRY_RUN
    end

    #---------------------------------------------------------------------------
    #  Archived::Intake::CtcIntake2021
    #---------------------------------------------------------------------------

    p '--------------------------------'
    # Destroy all Client records have CtcIntake2021-specific intakes.
    ActiveRecord::Base.transaction do
      f_client_ids = lambda { Archived::Intake::CtcIntake2021.pluck(:client_id).compact.uniq }
      client_ids = f_client_ids.call

      p 'Client records (and associated) for Archived::Intake::CtcIntake2021 ... '
      p 'Tally of Client records associated w/ CtcIntake2021 record BEFORE: ' + client_ids.length.to_s
      p 'Tally of CtcIntake2021 records BEFORE: ' + Archived::Intake::CtcIntake2021.count.to_s
      p 'Tally of all TaxReturn records BEFORE: ' + TaxReturn.count.to_s

      p 'Deleting ...' 
      client_ids.each { |id| Client.find(id).destroy! }
      p 'Deleted.'

      client_ids = f_client_ids.call
      p 'Tally of Client records associated w/ CtcIntake2021 record AFTER: ' + client_ids.length.to_s
      p 'Tally of CtcIntake2021 records AFTER: ' + Archived::Intake::CtcIntake2021.count.to_s
      p 'Tally of all TaxReturn records AFTER: ' + TaxReturn.count.to_s

      raise ActiveRecord::Rollback if DRY_RUN
    end

    #---------------------------------------------------------------------------
    #  Intake::CtcIntake
    #---------------------------------------------------------------------------

    p '--------------------------------'
    # Destroy client records having CtcIntake-specific intakes.
    # This should destroy associated intake, tax_returns, efile_submissions, documents, and has_one_attached items.
    ActiveRecord::Base.transaction do
      f_client_records = lambda { Client.select { |c| c.intake.class == Intake::CtcIntake } }
      client_records = f_client_records.call

      p 'Client records (and associated) for plain CtcIntakes ...'
      p 'Tally of Client records associated w/ CtcIntake record BEFORE: ' + client_records.size.to_s
      p 'Tally of CtcIntake records BEFORE: ' + Intake::CtcIntake.count.to_s
      p 'Tally of all TaxReturn records BEFORE: ' + TaxReturn.count.to_s

      p 'Deleting ...' 
      client_records.each(&:destroy!)
      p 'Deleted.'

      client_records = f_client_records.call
      p 'Tally of Client records associated w/ CtcIntake record AFTER: ' + client_records.size.to_s
      p 'Tally of CtcIntake records AFTER: ' + Intake::CtcIntake.count.to_s
      p 'Tally of all TaxReturn records AFTER: ' + TaxReturn.count.to_s

      raise ActiveRecord::Rollback if DRY_RUN
    end

    p '--------------------------------'
    # Destroy CTC-related DriversLicense records.
    ActiveRecord::Base.transaction do
      p 'CTC DriversLicense records ...'
      p 'Tally BEFORE: ' + drivers_license_tally(saved_ctc_drivers_license_ids).to_s

      # These IDs were saved at the beginning of the script.
      saved_ctc_drivers_license_ids.each { |id| DriversLicense.find(id).destroy! }

      p 'Tally AFTER: ' + drivers_license_tally(saved_ctc_drivers_license_ids).to_s

      raise ActiveRecord::Rollback if DRY_RUN
    end

    #---------------------------------------------------------------------------
    #  delete remaining TaxReturn 
    #---------------------------------------------------------------------------

    p '--------------------------------'
    # Destroy any remaining TaxReturn records where is_ctc is true (if any). (It's not clear
    # if the `is_ctc` flag is/was being used consistently, at least based on the data
    # in seeder.rb; hence this extra step just for thoroughness.)
    ActiveRecord::Base.transaction do
      f_rcds = lambda { TaxReturn.where(is_ctc: true) }
      rcds = f_rcds.call

      p 'Remaining TaxRecords (if any) where `is_ctc` is true'
      p 'Tally BEFORE: ' + rcds.size.to_s

      p 'Deleting ...' 
      rcds.each(&:destroy!)
      p 'Deleted.'

      rcds = f_rcds.call
      p 'Tally AFTER: ' + rcds.size.to_s

      raise ActiveRecord::Rollback if DRY_RUN
    end

    #---------------------------------------------------------------------------
    #  CTC EfileError
    #---------------------------------------------------------------------------

    p '--------------------------------'
    ActiveRecord::Base.transaction do
      EfileError.where(service_type: :ctc).each(&:destroy!)
      p 'Destroyed CTC EfileError records.'

      raise ActiveRecord::Rollback if DRY_RUN
    end

    p '--------------------------------'
    p 'FINISHED delete_ctc_data:perform'
    p '--------------------------------'

    if DRY_RUN
      p 'This was a DRY RUN! Nothing was deleted.'
    end
  end
end
