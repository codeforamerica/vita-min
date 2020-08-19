require 'rails_helper'

RSpec.describe AnonymizedIntakeCsvService do
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
          expect(row[header].to_s)
            .to eq(subject.decorated_intake(intake).send(field).to_s)
            .and be_present
        end
      end
    end

    context "intake status columns" do
      before do
        create(
          :ticket_status,
          intake: intake_1,
          created_at: DateTime.new(2020, 1, 1),
          intake_status: EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
        )
        create(
          :ticket_status,
          intake: intake_1,
          created_at: DateTime.new(2020, 1, 2),
          intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_REVIEW,
        )
        create(
          :ticket_status,
          intake: intake_2,
          verified_change: false,
          created_at: DateTime.new(2020, 1, 3),
          intake_status: EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
        )
        create(
          :ticket_status,
          intake: intake_2,
          created_at: DateTime.new(2020, 1, 4),
          intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_REVIEW,
        )
      end

      it "stores timestamps in the appropriate column" do
        row_1_csv_data = csv[0]
        expect(row_1_csv_data["Intake Status - Gathering Documents"]).to eq("2020-01-01 00:00:00 UTC")
        expect(row_1_csv_data["Intake Status - In Review"]).to eq("2020-01-02 00:00:00 UTC")
        row_2_csv_data = csv[1]
        expect(row_2_csv_data["Intake Status - Gathering Documents"]).to be_nil
        expect(row_2_csv_data["Intake Status - In Review"]).to eq("2020-01-04 00:00:00 UTC")
      end
    end

    context "return status columns" do
      before do
        create(
          :ticket_status,
          intake: intake_1,
          created_at: DateTime.new(2020, 1, 1),
          return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
        )
        create(
          :ticket_status,
          intake: intake_1,
          created_at: DateTime.new(2020, 1, 2),
          return_status: EitcZendeskInstance::RETURN_STATUS_DO_NOT_FILE
        )
        create(
          :ticket_status,
          intake: intake_2,
          verified_change: false,
          created_at: DateTime.new(2020, 1, 3),
          return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
        )
        create(
          :ticket_status,
          intake: intake_2,
          created_at: DateTime.new(2020, 1, 4),
          return_status: EitcZendeskInstance::RETURN_STATUS_DO_NOT_FILE
        )
      end

      context "if we know about any status changes" do
        it "stores timestamps in the right column" do
          row_1_csv_data = csv[0]
          expect(row_1_csv_data["Return Status - In Progress"]).to eq("2020-01-01 00:00:00 UTC")
          expect(row_1_csv_data["Return Status - Do Not File"]).to eq("2020-01-02 00:00:00 UTC")
          row_2_csv_data = csv[1]
          expect(row_2_csv_data["Return Status - In Progress"]).to be_nil
          expect(row_2_csv_data["Return Status - Do Not File"]).to eq("2020-01-04 00:00:00 UTC")
        end
      end
    end

    context "EIP-only status columns" do
      before do
        create(
          :ticket_status,
          intake: intake_1,
          created_at: DateTime.new(2020, 1, 1),
          eip_status: EitcZendeskInstance::EIP_STATUS_ID_UPLOAD
        )
        create(
          :ticket_status,
          intake: intake_1,
          created_at: DateTime.new(2020, 1, 2),
          eip_status: EitcZendeskInstance::EIP_STATUS_SUBMITTED
        )
        create(
          :ticket_status,
          intake: intake_2,
          verified_change: false,
          created_at: DateTime.new(2020, 1, 3),
          eip_status: EitcZendeskInstance::EIP_STATUS_ID_UPLOAD
        )
        create(
          :ticket_status,
          intake: intake_2,
          created_at: DateTime.new(2020, 1, 4),
          eip_status: EitcZendeskInstance::EIP_STATUS_SUBMITTED
        )
      end

      context "there are EIP status events" do
        it "stores timestamps in the right column" do
          row_1_csv_data = csv[0]
          expect(row_1_csv_data["EIP Status - Reached ID upload page"]).to eq("2020-01-01 00:00:00 UTC")
          expect(row_1_csv_data["EIP Status - Submitted EIP only form"]).to eq("2020-01-02 00:00:00 UTC")
          row_2_csv_data = csv[1]
          expect(row_2_csv_data["EIP Status - Reached ID upload page"]).to be_nil
          expect(row_2_csv_data["EIP Status - Submitted EIP only form"]).to eq("2020-01-04 00:00:00 UTC")
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
