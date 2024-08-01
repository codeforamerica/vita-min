require "rails_helper"

describe Seeder do
  before do
    described_class.new.run
  end

  def count_rows_by_model
    rows = {}
    ApplicationRecord.descendants.each do |model|
      next if model.abstract_class?
      rows[model.name] = model.all.size
    end
    rows
  end

  it "creates some clients and intakes" do
    rows = count_rows_by_model
    expect(rows["Intake"]).to be >= 1
    expect(rows["Client"]).to be >= 1
  end

  it "does not create duplicate rows" do
    row_count_after_one_run = count_rows_by_model
    described_class.new.run
    expect(count_rows_by_model).to eq(row_count_after_one_run)
  end

  it "creates an eitc client under 24 with a qualifying child" do
    intake = Intake.find_by(primary_first_name: "EitcUnderTwentyFourQC")
    expect(intake.dependents.count).to eq 1
    expect(intake.dependents.first.qualifying_eitc?).to eq true
    expect(intake.client.efile_submissions.count).to eq 1
    expect(intake.client.efile_submissions.first.last_client_accessible_transition.exposed_error).to be_present
  end
end
