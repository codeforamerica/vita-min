namespace :backfill_full_time_student_time do
  desc "Backfill full_time_student_less_than_five_months with full_time_student_less_than_four_months value"
  task backfill: :environment do
    Intake::CtcIntake
      .where.not(full_time_student_less_than_four_months: "unfilled")
      .where(full_time_student_less_than_five_months: "unfilled")
      .find_in_batches(batch_size: 100) do |batch|
      batch.each do |intake|
        intake.update(full_time_student_less_than_five_months: intake.full_time_student_less_than_four_months)
      end
    end
  end
end