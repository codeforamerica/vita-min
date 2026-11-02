# Can run manually via:
#     bundle exec rake delete_ctc_data:perform[mode]
#     ... where mode is dry_run or destructive
namespace :delete_ctc_data do
  task :perform, [:mode] => :environment do |_task, args|
    p '--------------------------------'
    p 'STARTING delete_ctc_data:perform'
    p '--------------------------------'

    if ! ['dry_run', 'destructive'].include? args.mode
      p 'Specify mode, either dry_run or destructive'
      next
    end

    dry_run = args.mode == 'dry_run'
    if dry_run
      p 'DRY RUN! Nothing will be deleted.'
    end

    p 'Continue? Type YES and hit enter: '
    exit(0) unless STDIN.gets&.chomp == "YES"

    #---------------------------------------------------------------------------
    #  which clients to delete
    #---------------------------------------------------------------------------

    # clients with at least one ctc intake
    ctc_clients = Client.where(id: Intake::CtcIntake.select(:client_id))
                        .or(Client.where(id: Archived::Intake::CtcIntake2021.select(:client_id)))


    # clients with at least one ctc intake but also have another type of intake (shouldn't exist but just in case)
    non_ctc_intakes = Intake.where.not(type: Intake::CtcIntake.sti_name).or(Intake.where(type: nil))
    non_ctc_archived_intakes = Archived::Intake2021.where.not(type: Archived::Intake::CtcIntake2021.sti_name)
                                                   .or(Archived::Intake2021.where(type: nil))
    mixed_clients = ctc_clients.where(id: non_ctc_intakes.select(:client_id))
                               .or(ctc_clients.where(id: non_ctc_archived_intakes.select(:client_id)))

    # don't delete clients that have another type of intake
    clients_to_delete = ctc_clients.where.not(id: mixed_clients.select(:id))

    p '--------------------------------'
    p 'Tally of CTC Client records to delete: ' + clients_to_delete.count.to_s
    p 'Tally of CtcIntake records: ' + Intake::CtcIntake.count.to_s
    p 'Tally of CtcIntake2021 records: ' + Archived::Intake::CtcIntake2021.count.to_s
    p 'Tally of ClientInteraction records on those clients: ' + ClientInteraction.where(client_id: clients_to_delete.select(:id)).count.to_s
    p 'Tally of CTC Client records SKIPPED because they also have a non-CTC intake: ' + mixed_clients.count.to_s
    p 'Skipped Client ids: ' + mixed_clients.pluck(:id).inspect if mixed_clients.exists?

    #---------------------------------------------------------------------------
    #  delete each client in its own transaction
    #---------------------------------------------------------------------------

    delete_client = lambda do |client|
      ActiveRecord::Base.transaction do
        drivers_license_ids = Intake::CtcIntake.where(client_id: client.id)
                                               .pluck(:primary_drivers_license_id, :spouse_drivers_license_id)
                                               .flatten.compact

        document_ids = client.documents.pluck(:id)

        ExperimentParticipant.where(record_type: Intake.name, record_id: Intake.where(client_id: client.id).select(:id)).delete_all

        ClientInteraction.where(client_id: client.id).delete_all

        Archived::Intake::CtcIntake2021.where(client_id: client.id).find_each do |intake|
          intake.bank_account&.destroy!
          intake.dependents.each(&:destroy!)
          intake.delete
        end

        client.destroy!

        DriversLicense.where(id: drivers_license_ids).destroy_all

        PaperTrail::Version.where(item_type: Document.name, item_id: document_ids).delete_all
      end
    end

    #---------------------------------------------------------------------------
    #  general stuff
    #---------------------------------------------------------------------------

    delete_remaining_ctc_records = lambda do
      SystemNote::CtcPortalAction.find_each(&:destroy!)
      p 'Destroyed all CtcPortalAction records.'

      SystemNote::CtcPortalUpdate.find_each(&:destroy!)
      p 'Destroyed all CtcPortalUpdate records.'

      CtcSignup.find_each(&:destroy!)
      p 'Destroyed all CtcSignup records.'

      EfileError.where(service_type: :ctc).find_each(&:destroy!)
      p 'Destroyed CTC EfileError records.'
    end

    #---------------------------------------------------------------------------
    #  run
    #---------------------------------------------------------------------------

    p '--------------------------------'
    p 'Tally of CtcPortalAction records: ' + SystemNote::CtcPortalAction.count.to_s
    p 'Tally of CtcPortalUpdate records: ' + SystemNote::CtcPortalUpdate.count.to_s
    p 'Tally of CtcSignup records: ' + CtcSignup.count.to_s
    p 'Tally of CTC EfileError records: ' + EfileError.where(service_type: :ctc).count.to_s

    if dry_run
      p '--------------------------------'
      p 'FINISHED delete_ctc_data:perform'
      p 'This was a DRY RUN! Nothing was deleted.'
      p '--------------------------------'
      next
    end

    p '--------------------------------'
    p 'Deleting CTC Client records (and associated) ...'
    deleted_count = 0
    failed_client_ids = []
    clients_to_delete.find_each do |client|
      delete_client.call(client)
      deleted_count += 1
      p "Deleted #{deleted_count} clients so far ..." if (deleted_count % 1000).zero?
    rescue StandardError => e
      failed_client_ids << client.id
      p "Failed to delete Client #{client.id}: #{e.class}: #{e.message}"
    end
    p 'Deleted ' + deleted_count.to_s + ' clients.'
    p 'Failed Client ids: ' + failed_client_ids.inspect if failed_client_ids.any?
    p 'Tally of CTC Client records remaining: ' + clients_to_delete.count.to_s

    p '--------------------------------'
    delete_remaining_ctc_records.call

    #-------------------------------------------------------------------------
    #  report (not delete) remaining is_ctc TaxReturns
    #-------------------------------------------------------------------------

    p '--------------------------------'
    remaining_is_ctc_returns = TaxReturn.where(is_ctc: true)
    p 'Remaining TaxReturn records where `is_ctc` is true (NOT deleted, review manually): ' + remaining_is_ctc_returns.count.to_s
    p 'TaxReturn ids: ' + remaining_is_ctc_returns.pluck(:id).inspect if remaining_is_ctc_returns.exists?

    p '--------------------------------'
    p 'FINISHED delete_ctc_data:perform'
    p '--------------------------------'
  end
end
