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


  desc "Reformat months_in_home to match new mapping"
  task reformat_months_in_home: :environment do
    # released at Wed Aug 10 13:27:48 2022 -0700
    Dependent.where("created_at >= ?", DateTime.parse('Wed Aug 10 13:27:48 2022 -0700')).where(lived_with_more_than_six_months: "unfilled").find_in_batches(batch_size: 100) do |batch|
      batch.each do |dependent|
        next if dependent.intake.claim_eitc_yes? || dependent.months_in_home.nil? || dependent.months_in_home.to_i > 11

        dependent.update!(months_in_home: dependent.months_in_home.to_i + 1)
      end
    end
  end
end