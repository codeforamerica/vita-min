require "rails_helper"

describe "backfill_incorrect_demographic_data:backfill" do
  include_context "rake"
  let(:botched_intake_full) {
    create(
      :gyr_intake,
      :filled_out,
      demographic_primary_american_indian_alaska_native: true,
      demographic_primary_asian: true,
      demographic_primary_black_african_american: true,
      demographic_primary_native_hawaiian_pacific_islander: true,
      demographic_primary_white: true,
      demographic_primary_prefer_not_to_answer_race: true,
      demographic_spouse_american_indian_alaska_native: true,
      demographic_spouse_asian: true,
      demographic_spouse_black_african_american: true,
      demographic_spouse_native_hawaiian_pacific_islander: true,
      demographic_spouse_white: true,
      demographic_spouse_prefer_not_to_answer_race: true,
    )
  }
  let(:botched_intake_partial) {
    create(
      :gyr_intake,
      :filled_out,
      demographic_primary_asian: true,
      demographic_spouse_american_indian_alaska_native: true,
      demographic_spouse_asian: true,
      demographic_spouse_black_african_american: true,
      demographic_spouse_native_hawaiian_pacific_islander: true,
      demographic_spouse_white: true,
      demographic_spouse_prefer_not_to_answer_race: true,
    )
  }
  let(:legit_intake) {
    create(
      :gyr_intake,
      :filled_out,
      demographic_primary_asian: true,
      demographic_primary_white: true,
      demographic_spouse_prefer_not_to_answer_race: true,
    )
  }
  let(:legit_intake_multiracial) {
    create(
      :gyr_intake,
      :filled_out,
      demographic_primary_asian: true,
      demographic_spouse_prefer_not_to_answer_race: true,
      demographic_spouse_black_african_american: true,
      demographic_spouse_native_hawaiian_pacific_islander: true,
    )
  }

  it "resets the set of answers for each filer to nil if the whole set (including prefer not to anwer) was true" do
    expect(
      task.invoke
    ).not_to change(legit_intake).and not_change(legit_intake_multiracial)

    botched_intake_full.reload
    expect(botched_intake_full.demographic_primary_american_indian_alaska_native).to be_nil
    expect(botched_intake_full.demographic_primary_asian).to be_nil
    expect(botched_intake_full.demographic_primary_black_african_american).to be_nil
    expect(botched_intake_full.demographic_primary_native_hawaiian_pacific_islander).to be_nil
    expect(botched_intake_full.demographic_primary_white).to be_nil
    expect(botched_intake_full.demographic_primary_prefer_not_to_answer_race).to be_nil
    expect(botched_intake_full.demographic_spouse_american_indian_alaska_native).to be_nil
    expect(botched_intake_full.demographic_spouse_asian).to be_nil
    expect(botched_intake_full.demographic_spouse_black_african_american).to be_nil
    expect(botched_intake_full.demographic_spouse_native_hawaiian_pacific_islander).to be_nil
    expect(botched_intake_full.demographic_spouse_white).to be_nil
    expect(botched_intake_full.demographic_spouse_prefer_not_to_answer_race).to be_nil

    botched_intake_partial.reload
    expect(botched_intake_partial.demographic_primary_asian).to be_nil
    expect(botched_intake_partial.demographic_spouse_american_indian_alaska_native).to be_nil
    expect(botched_intake_partial.demographic_spouse_asian).to be_nil
    expect(botched_intake_partial.demographic_spouse_black_african_american).to be_nil
    expect(botched_intake_partial.demographic_spouse_native_hawaiian_pacific_islander).to be_nil
    expect(botched_intake_partial.demographic_spouse_white).to be_nil
    expect(botched_intake_partial.demographic_spouse_prefer_not_to_answer_race).to be_nil
  end
end
