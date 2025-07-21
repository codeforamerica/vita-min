namespace :state_file do
  namespace :ty24 do
    desc 'Archive intakes for a specific state'
    task :archive, [:state_code] => :environment do |_t, args|
      Rails.logger = Logger.new($stdout)
      # we batch these since archiving involves copying the submission pdf to a new location in s3
      StateFile::Ty24ArchiverService.archive!(
        state_code: args[:state_code],
        batch_size: 50
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
