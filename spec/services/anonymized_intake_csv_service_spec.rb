require 'rails_helper'

RSpec.describe AnonymizedIntakeCsvService do
  let!(:vita_partner) { create(:organization) }
  let(:intake_1) { create(:intake, :filled_out) }
  let(:intake_2) { create(:intake, :filled_out) }
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
    let(:expected_headers) { AnonymizedIntakeCsvService::CSV_HEADERS }
    let(:csv_mapping) do
      expected_headers.zip(AnonymizedIntakeCsvService::CSV_FIELDS).to_h
    end
    let(:csv) { CSV.parse(subject.generate_csv, headers: true) }

    it "includes a column for each desired field" do
      expect(csv.headers).to include(*expected_headers)
    end

    it "adds a row with every field for every Intake provided" do
      [intake_1, intake_2].each_with_index do |intake, index|
        row = csv[index]
        csv_mapping.each do |header, field|
          puts(header) unless row[header].present?
          expect(row[header].to_s)
            .to eq(subject.decorated_intake(intake).send(field).to_s)
            .and be_present # this expects the sample intake to have every field filled out, so that we can check the value
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
