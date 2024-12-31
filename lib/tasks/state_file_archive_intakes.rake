namespace :state_file do
  namespace :ty23 do
    desc 'find archivable az intakes and create their archival record'
    task archive_az_intakes: :environment do
      batch_size = 100 # we batch these since archiving involves copying the submission pdf to a new location in s3
      archiver = StateFile::Ty23ArchiverService.new('az', batch_size)
      archiver.find_archiveables # sets `current_batch` on the archiver instance
      while archiver.current_batch.count > 0 # keep archiving, in batches, until the archiver doesn't find anything else
        archiver.archive_batch # process the batch
        archiver.find_archiveables # set the next batch
      end
    end

    desc 'find archivable ny intakes and create their archival record'
    task archive_ny_intakes: :environment do
      batch_size = 100 # we batch these since archiving involves copying the submission pdf to a new location in s3
      archiver = StateFile::Ty23ArchiverService.new('ny', batch_size)
      archiver.find_archiveables # sets `current_batch` on the archiver instance
      while archiver.current_batch.count > 0 # keep archiving, in batches, until the archiver doesn't find anything else
        archiver.archive_batch # process the batch
        archiver.find_archiveables # set the next batch
      end
    end
  end
end
