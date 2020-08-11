require 'rails_helper'

RSpec.describe AnonymizedDiyIntakeCsvService do
  let(:filled_diy_intake) { create(:diy_intake, :filled_out) }
  let(:unfilled_diy_intake) { create(:diy_intake) }
  let(:filled_diy_intake_2) { create(:diy_intake, :filled_out) }

  let(:ids) { [filled_diy_intake.id, unfilled_diy_intake.id] }
  let(:subject) { AnonymizedDiyIntakeCsvService.new(ids) }

  describe "#records" do
    it "returns an ActiveRecord::Relation to retrieve the diy_intakes for given ids" do
      expect(subject.records).to be_an(ActiveRecord::Relation)
      expect(subject.records).to contain_exactly(filled_diy_intake, unfilled_diy_intake)
    end

    context "when there are no diy_intake ids passed in" do
      let(:ids) { nil }

      it "returns all records with a ticket id" do
        expect(subject.records).to contain_exactly(filled_diy_intake, filled_diy_intake_2)
      end
    end
  end

  describe "#generate_csv" do
    let(:expected_headers) { AnonymizedDiyIntakeCsvService::CSV_HEADERS }
    let(:csv_mapping) do
      expected_headers.zip(AnonymizedDiyIntakeCsvService::CSV_FIELDS).to_h
    end
    let(:csv) { CSV.parse(subject.generate_csv, headers: true) }

    it "includes a column for each desired field" do
      expect(csv.headers).to include(*expected_headers)
    end

    it "adds a row with every field for every Intake provided" do
      [filled_diy_intake, unfilled_diy_intake].each_with_index do |diy_intake, index|
        row = csv[index]
        csv_mapping.each do |header, field|
          expect(row[header].to_s)
            .to eq(diy_intake.send(field).to_s)
        end
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
