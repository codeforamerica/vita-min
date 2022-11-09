namespace :backfill_full_time_student_time do
  desc "Backfill full_time_student_less_than_five_months with full_time_student_less_than_four_months value"
  task backfill: :environment do
    Intake::CtcIntake
      .where.not(full_time_student_less_than_four_months: "unfilled")
      .where(full_time_student_less_than_five_months: "unfilled")
      .in_batches(of: 10000) do |batch|
      batch.update_all('full_time_student_less_than_five_months = full_time_student_less_than_four_months')
    end
  end
end