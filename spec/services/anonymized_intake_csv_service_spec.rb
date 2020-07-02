require 'rails_helper'

RSpec.describe AnonymizedIntakeCsvService do
  let(:intake_1) do
    create(:intake,
      completed_at: Date.new(2020, 7, 1),
      locale: "en",
      source: "thc"
    )
  end
  let(:intake_2) do
    create(:intake,
      completed_at: Date.new(2020, 7, 2),
      locale: "es",
      source: "uwkc"
    )
  end
  let!(:intake_3) { create(:intake) }
  let(:intake_ids) { [intake_1.id, intake_2.id] }
  let(:subject) { AnonymizedIntakeCsvService.new(intake_ids) }

  describe "#intakes" do
    it "returns an ActiveRecord::Relation to retrieve the intakes for given ids" do
      expect(subject.intakes).to be_an(ActiveRecord::Relation)
      expect(subject.intakes).to contain_exactly(intake_1, intake_2)
    end

    context "when there are no intake ids passed in" do
      let(:intake_ids) { nil }

      it "returns an ActiveRecord::Relation for all intakes" do
        expect(subject.intakes).to be_an(ActiveRecord::Relation)
        expect(subject.intakes).to contain_exactly(intake_1, intake_2, intake_3)
      end
    end
  end

  describe "#generate_csv" do
    let(:expected_headers) do
      %w{
        completed_at
        locale
        intake_source
      }
    end
    let(:csv) { CSV.parse(subject.generate_csv, headers: true) }

    it "includes a column for each desired field" do
      expect(csv.headers).to include(*expected_headers)
    end

    it "adds a row for every Intake provided" do
      [intake_1, intake_2].each_with_index do |intake, index|
        row = csv[index]
        expect(row["completed_at"]).to eq(intake.completed_at.to_s)
        expect(row["locale"]).to eq(intake.locale.to_s)
        expect(row["intake_source"]).to eq(intake.source.to_s)
      end
    end
  end

  describe "#store_csv" do
    it "saves the csv in a AnonymizedIntakeCsvExtract with record count and time of run" do
      extract = subject.store_csv
      expect(extract.record_count).to eq(2)
      expect(extract.upload).to be_attached
      expect(extract.run_at).to be_within(1.second).of(Time.now)
    end
  end
end
