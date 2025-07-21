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

  namespace :ty24 do
    desc 'Archive intakes for a specific state'
    task :archive, [:state_code] => :environment do |_t, args|
      Rails.logger = Logger.new($stdout)
      StateFile::Ty24ArchiverService.archive!(
        state_code: args[:state_code],
        batch_size: 10
      )
    end

    desc 'Archive AZ intakes'
    task archive_az: :environment do
      Rake::Task['state_file:ty24:archive'].invoke('az')
    end

    desc 'Archive ID intakes'
    task archive_id: :environment do
      Rake::Task['state_file:ty24:archive'].invoke('id')
    end

    desc 'Archive MD intakes'
    task archive_md: :environment do
      Rake::Task['state_file:ty24:archive'].invoke('md')
    end

    desc 'Archive NJ intakes'
    task archive_nj: :environment do
      Rake::Task['state_file:ty24:archive'].invoke('nj')
    end

    desc 'Archive NC intakes'
    task archive_nc: :environment do
      Rake::Task['state_file:ty24:archive'].invoke('nc')
    end
  end
end
