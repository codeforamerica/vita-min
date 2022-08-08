namespace :dependents do
  desc "Backfill months_in_home with lived_with_more_than_six_months value"
  task backfill_months_in_home: :environment do
    Dependent.where(months_in_home: nil).where.not(lived_with_more_than_six_months: "unfilled").find_in_batches(batch_size: 100) do |batch|
      batch.each do |dependent|
        if dependent.lived_with_more_than_six_months_yes?
          dependent.update!(months_in_home: 7)
        else
          dependent.update!(months_in_home: 6)
        end
      end
    end
  end
end