require "rails_helper"

describe "backfill_full_time_student_time:backfill" do
  include_context "rake"

  let!(:gyr_intake) { create(:intake, full_time_student_less_than_four_months: 0) }
  let!(:ctc_intake_default_value) { create(:ctc_intake, full_time_student_less_than_four_months: "unfilled") }
  let!(:ctc_intake_value_yes) { create(:ctc_intake, full_time_student_less_than_four_months: "yes") }
  let!(:ctc_intake_value_no) { create(:ctc_intake, full_time_student_less_than_four_months: "no") }

  it "copies the full_time_student_less_than_four_months to full_time_student_less_than_five_months" do
    expect {
      task.invoke
    }.to change { ctc_intake_value_yes.reload.full_time_student_less_than_five_months }.from("unfilled").to("yes")
     .and change { ctc_intake_value_no.reload.full_time_student_less_than_five_months }.from("unfilled").to("no")
     .and not_change { gyr_intake.reload.full_time_student_less_than_five_months }
     .and not_change { ctc_intake_default_value.reload.full_time_student_less_than_five_months }
  end
end
