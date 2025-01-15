namespace :state_file do
  namespace :ty23 do
    desc 'find archiveable az intakes and create their archival record'
    task archive_az_intakes: :environment do
      Rails.logger = Logger.new($stdout)
      batch_size = 10 # we batch these since archiving involves copying the submission pdf to a new location in s3
      archiver = StateFile::Ty23ArchiverService.new(state_code: 'az', batch_size: batch_size)
      archiver.find_archiveables # sets `current_batch` on the archiver instance
      while archiver.current_batch.count.positive? # keep archiving, in batches, until the archiver doesn't find anything else
        archiver.archive_batch # process the batch
        archiver.find_archiveables # set the next batch
      end
    end

    desc 'find archiveable ny intakes and create their archival record'
    task archive_ny_intakes: :environment do
      Rails.logger = Logger.new($stdout)
      batch_size = 10 # we batch these since archiving involves copying the submission pdf to a new location in s3
      archiver = StateFile::Ty23ArchiverService.new(state_code: 'ny', batch_size: batch_size)
      archiver.find_archiveables # sets `current_batch` on the archiver instance
      while archiver.current_batch.count.positive? # keep archiving, in batches, until the archiver doesn't find anything else
        archiver.archive_batch # process the batch
        archiver.find_archiveables # set the next batch
      end
    end
  end
end
