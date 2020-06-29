require 'rails_helper'

describe Zendesk::DuplicateIntakeMatcher do
  let!(:original_intake) do
    create(:intake,
      preferred_name: "George Bell, jr.",
      email_address: "george.bell@gmail.com",
      phone_number: "1234567890",
      intake_ticket_id: 12345,
      needs_help_2018: "yes",
      needs_help_2019: "yes")
  end
  let!(:duplicate_intake) do
    create(:intake,
      preferred_name: "George bell, JR.",
      email_address: "George.bell@gmail.com",
      phone_number: "1234567890",
      intake_ticket_id: 23456,
      needs_help_2018: "yes",
      needs_help_2019: "yes")
    end
  let!(:_other_year_intake) do
    create(:intake, original_intake.attributes.except("id").merge(needs_help_2018: "no"))
  end
  let!(:_other_name_intake) do
    create(:intake,
      preferred_name: "George ball",
      email_address: "George.ball@gmail.com",
      phone_number: "1234567890",
      intake_ticket_id: 34567)
  end

  describe ".strong_matches" do
    it "groups by preferred_name, email and phone_number" do
      matches = subject.strong_matches
      expect(matches.size).to eq(1)
      expect(matches[0].intake_ids)
        .to contain_exactly(original_intake.id, duplicate_intake.id)
    end
  end

  describe ".run" do
    let(:merging_service) { Zendesk::TicketMergingService.new }
    let(:primary_id) { original_intake.intake_ticket_id }
    let(:mapping) do
      [original_intake, duplicate_intake].each_with_object({}) do |intake, hash|
        hash[intake.id] = intake.intake_ticket_id
      end
    end
    let(:expected_csv) do
      <<~CSV
          name,email,phone,filing years,intake ticket mapping,primary ticket id
          \"george bell, jr.\",george.bell@gmail.com,1234567890,\"2019, 2018\",\"#{mapping}\",#{primary_id}
      CSV
    end

    before do
      allow(merging_service).to receive(:find_primary_ticket)
        .and_return(double(id: primary_id))
      allow(subject).to receive(:merging_service).and_return(merging_service)
    end

    context "when dry_run is true" do
      it "returns a csv of the matches with primary ticket identified" do
        csv = subject.run
        expect(csv).to eq(expected_csv)
      end
    end

    context "when dry_run is false" do
      it "uses the TicketMergingService to merge the duplicates intakes" do
        expect(merging_service).to receive(:merge_duplicate_tickets)
          .with([original_intake.id, duplicate_intake.id])
        csv = subject.run(false)
        expect(csv).to eq(expected_csv)
      end
    end
  end
end
