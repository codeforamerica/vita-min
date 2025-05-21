require "rails_helper"

describe "needs_help_data_clean_up:backfill_needs_help" do
  include_context "rake"

  let!(:intake_2022) do
    create :intake,
           product_year: 2022,
           needs_help_2021: "yes",
           needs_help_2020: "no",
           needs_help_2019: "no",
           needs_help_2018: "yes",
           needs_help_current_year: "unfilled",
           needs_help_previous_year_1: "unfilled",
           needs_help_previous_year_2: "unfilled",
           needs_help_previous_year_3: "unfilled"
  end
  let!(:intake_2023) do
    create :intake,
           product_year: 2023,
           needs_help_2021: "no",
           needs_help_2020: "no",
           needs_help_2019: "no",
           needs_help_2018: "no",
           needs_help_current_year: "yes",
           needs_help_previous_year_1: "yes",
           needs_help_previous_year_2: "yes",
           needs_help_previous_year_3: "yes"
  end

  it "changes fields for 2022 product year intake" do
    task.invoke
    expect(intake_2022.reload.needs_help_current_year).to eq("yes")
    expect(intake_2022.reload.needs_help_previous_year_1).to eq("no")
    expect(intake_2022.reload.needs_help_previous_year_2).to eq("no")
    expect(intake_2022.reload.needs_help_previous_year_3).to eq("yes")
  end

  it "does not change fields for the 2023 product year intakes" do
    task.invoke
    expect(intake_2023.reload.needs_help_current_year).to eq("yes")
    expect(intake_2023.reload.needs_help_previous_year_1).to eq("yes")
    expect(intake_2023.reload.needs_help_previous_year_2).to eq("yes")
    expect(intake_2023.reload.needs_help_previous_year_3).to eq("yes")
  end
end
