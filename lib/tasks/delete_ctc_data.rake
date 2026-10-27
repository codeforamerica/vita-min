# Can run manually via:
#     bundle exec rake delete_ctc_data:perform[mode]
#     ... where mode is dry_run or destructive
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

    if ! ['dry_run', 'destructive'].include? args.mode
      p 'Specify mode, either dry_run or destructive'
      next
    end

    dry_run = true if args.mode != 'destructive'
    if dry_run
      p 'DRY RUN! Nothing will be deleted.'
    end

    p 'Continue? Type YES and hit enter: '
    resp = STDIN.gets
    if resp.chomp != "YES"; exit(0); end

    #---------------------------------------------------------------------------
    delete_all_ctc_data = lambda do

      #-------------------------------------------------------------------------
      #  prep
      #-------------------------------------------------------------------------

      # Save DriversLicense IDs as a preliminary step; then we'll destroy the
      # DriversLicense records later. (A PG::ForeignKeyViolation error
      # occurs if attempting to destroy a DriversLicense record when an existing Intake
      # record has a `primary_drivers_license_id` or `spouse_drivers_license_id`
      # referring to the DriversLicense record in question.)
      saved_ctc_drivers_license_ids = get_drivers_license_ids_for_ctc_intakes

      #-------------------------------------------------------------------------
      #  general stuff
      #-------------------------------------------------------------------------

      p '--------------------------------'
      # Destroy all SystemNote::CtcPortalAction
      SystemNote::CtcPortalAction.all.each(&:destroy!) 
      p 'Destroyed all CtcPortalAction records.'

      p '--------------------------------'
      # Destroy all SystemNote::CtcPortalUpdate
      SystemNote::CtcPortalUpdate.all.each(&:destroy!)
      p 'Destroyed all CtcPortalUpdate records.'

      p '--------------------------------'
      # Destroy all CtcSignup records.
      CtcSignup.all.each(&:destroy!)
      p 'Destroyed all CtcSignup records.'

      #-------------------------------------------------------------------------
      #  Archived::Intake::CtcIntake2021
      #-------------------------------------------------------------------------

      p '--------------------------------'
      # Destroy all Client records have CtcIntake2021-specific intakes.
      f_client_ids = lambda { Archived::Intake::CtcIntake2021.pluck(:client_id).compact.uniq }
      client_ids = f_client_ids.call

      p 'Client records (and associated) for Archived::Intake::CtcIntake2021 ... '
      p 'Tally of Client records associated w/ CtcIntake2021 record BEFORE: ' + client_ids.length.to_s
      p 'Tally of CtcIntake2021 records BEFORE: ' + Archived::Intake::CtcIntake2021.count.to_s
      p 'Tally of all TaxReturn records BEFORE: ' + TaxReturn.count.to_s

      p 'Deleting ...' 
      Archived::Intake::CtcIntake2021.find_each do |intake|
        intake.bank_account&.destroy!
        intake.dependents.each(&:destroy!)
        intake.delete
      end
      client_ids.each { |id| Client.find(id).destroy! }
      p 'Deleted.'

      client_ids = f_client_ids.call
      p 'Tally of Client records associated w/ CtcIntake2021 record AFTER: ' + client_ids.length.to_s
      p 'Tally of CtcIntake2021 records AFTER: ' + Archived::Intake::CtcIntake2021.count.to_s
      p 'Tally of all TaxReturn records AFTER: ' + TaxReturn.count.to_s

      #-------------------------------------------------------------------------
      #  Intake::CtcIntake
      #-------------------------------------------------------------------------

      p '--------------------------------'
      # Destroy client records having CtcIntake-specific intakes.
      # This should destroy associated intake, tax_returns, efile_submissions, documents, and has_one_attached items.
      client_records = Client.where(id: Intake::CtcIntake.select(:client_id))

      p 'Client records (and associated) for plain CtcIntakes ...'
      p 'Tally of Client records associated w/ CtcIntake record BEFORE: ' + client_records.size.to_s
      p 'Tally of CtcIntake records BEFORE: ' + Intake::CtcIntake.count.to_s
      p 'Tally of all TaxReturn records BEFORE: ' + TaxReturn.count.to_s

      p 'Deleting ...' 
      client_records.each(&:destroy!)
      p 'Deleted.'

      client_records_after_tally = Client.where(id: Intake::CtcIntake.select(:client_id)).count
      p 'Tally of Client records associated w/ CtcIntake record AFTER: ' + client_records_after_tally.to_s
      p 'Tally of CtcIntake records AFTER: ' + Intake::CtcIntake.count.to_s
      p 'Tally of all TaxReturn records AFTER: ' + TaxReturn.count.to_s

      p '--------------------------------'
      # Destroy CTC-related DriversLicense records.
      p 'CTC DriversLicense records ...'
      p 'Tally BEFORE: ' + drivers_license_tally(saved_ctc_drivers_license_ids).to_s

      # These IDs were saved at the beginning of the script.
      saved_ctc_drivers_license_ids.each { |id| DriversLicense.find(id).destroy! }

      p 'Tally AFTER: ' + drivers_license_tally(saved_ctc_drivers_license_ids).to_s

      #-------------------------------------------------------------------------
      #  delete any remaining CTC TaxReturns
      #-------------------------------------------------------------------------

      p '--------------------------------'
      # Destroy any remaining TaxReturn records where is_ctc is true (if any). (It's not clear
      # if the `is_ctc` flag is/was being used consistently, at least based on the data
      # in seeder.rb; hence this extra step just for thoroughness.)
      f_rcds = lambda { TaxReturn.where(is_ctc: true) }
      rcds = f_rcds.call

      p 'Remaining TaxRecords (if any) where `is_ctc` is true'
      p 'Tally BEFORE: ' + rcds.size.to_s

      p 'Deleting ...' 
      rcds.each(&:destroy!)
      p 'Deleted.'

      rcds = f_rcds.call
      p 'Tally AFTER: ' + rcds.size.to_s

      #-------------------------------------------------------------------------
      #  CTC EfileError
      #-------------------------------------------------------------------------

      p '--------------------------------'
      EfileError.where(service_type: :ctc).each(&:destroy!)
      p 'Destroyed CTC EfileError records.'

    end # end of lambda
    #---------------------------------------------------------------------------

    if dry_run
      ActiveRecord::Base.transaction do
        delete_all_ctc_data.call
        raise ActiveRecord::Rollback
      end
    else
      ActiveRecord::Base.transaction do
        delete_all_ctc_data.call
      end
    end

    p '--------------------------------'
    p 'FINISHED delete_ctc_data:perform'
    p '--------------------------------'

    if dry_run
      p 'This was a DRY RUN! Nothing was deleted.'
    end
  end
end
