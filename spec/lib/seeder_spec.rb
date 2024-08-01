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

  it "creates an GYR client with an intake" do
    intake = Intake.find_by(primary_first_name: "Captain")
    expect(intake.tax_returns.count).to eq 2
    expect(intake.client.vita_partner).to eq VitaPartner.find_by(name: "Oregano Org")
  end
end
