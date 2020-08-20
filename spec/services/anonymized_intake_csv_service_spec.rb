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
      end

      it "stores timestamps in the appropriate column" do
        expect(csv[0]["Intake Status - Gathering Documents"]).to eq("2020-01-01 00:00:00 UTC")
      end
    end

    context "with two TicketStatus events notifying about the same status" do
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
          intake_status: EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
          )
      end

      it "stores the timestamp of the earliest one" do
        expect(csv[0]["Intake Status - Gathering Documents"]).to eq("2020-01-01 00:00:00 UTC")
      end
    end

    context "with a non-verified_change TicketStatus" do
      before do
        create(
          :ticket_status,
          intake: intake_1,
          verified_change: false,
          created_at: DateTime.new(2020, 1, 1),
          intake_status: EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
          )
      end

      it "stores a nil timestamp for that status" do
        expect(csv[0]["Intake Status - Gathering Documents"]).to be_nil
      end
    end

    context "for return status columns" do
      before do
        create(
          :ticket_status,
          intake: intake_1,
          created_at: DateTime.new(2020, 1, 1),
          return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
        )
      end

      it "stores timestamps in the right column" do
        expect(csv[0]["Return Status - In Progress"]).to eq("2020-01-01 00:00:00 UTC")
      end
    end

    context "for EIP-only status columns" do
      before do
        create(
          :ticket_status,
          intake: intake_1,
          created_at: DateTime.new(2020, 1, 1),
          eip_status: EitcZendeskInstance::EIP_STATUS_ID_UPLOAD
        )
      end

      it "stores timestamps in the right column" do
          expect(csv[0]["EIP Status - Reached ID upload page"]).to eq("2020-01-01 00:00:00 UTC")
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
