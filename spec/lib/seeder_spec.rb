require "rails_helper"

describe Seeder do
  before do
    described_class.new.run
  end

  def count_rows_by_model
    rows = {}
    ApplicationRecord.descendants.each do |model|
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
end
