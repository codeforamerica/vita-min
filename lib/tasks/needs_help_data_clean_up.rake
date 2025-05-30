namespace :needs_help_data_clean_up do
  desc "Backfill intake 'needs_help' columns based on product year"

  task backfill_needs_help: :environment do
    batch_size = 500
    target_years = [2022]

    Intake.where(product_year: target_years).find_in_batches(batch_size: batch_size) do |batch|
      puts "*****Processing batch of #{batch.size} intakes*****"

      batch.each do |intake|
        product_year = intake.product_year.to_i

        updated_attrs = {
          needs_help_current_year: intake.send("needs_help_#{product_year - 1}"),
          needs_help_previous_year_1: intake.send("needs_help_#{product_year - 2}"),
          needs_help_previous_year_2: intake.send("needs_help_#{product_year - 3}"),
          needs_help_previous_year_3: intake.send("needs_help_#{product_year - 4}"),
        }

        intake.update!(updated_attrs)
      rescue => e
        Rails.logger.error("----*Failed to update intake #{intake.id}: #{e.message}*----")
      end
    end

    puts "*****Done!*****"
  end
end
