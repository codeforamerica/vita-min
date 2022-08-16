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


  desc "Format months_in_home for non-EITC dependents created so that they are either 6 or 7 months"
  task format_non_eitc_months_in_home: :environment do
    # released at Wed Aug 10 13:27:48 2022 -0700
    Dependent.where("created_at >= ?", DateTime.parse(' Wed Aug 10 13:27:48 2022 -0700')).find_in_batches(batch_size: 100) do |batch|
      batch.each do |dependent|
        next if dependent.intake.claim_eitc_yes?
        if dependent.months_in_home.to_i >= 6
          dependent.update!(months_in_home: 7)
        else
          dependent.update!(months_in_home: 6)
        end
      end
    end
  end
end