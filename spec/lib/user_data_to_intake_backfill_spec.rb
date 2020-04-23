require "rails_helper"

RSpec.describe UserDataToIntakeBackfill do
  describe ".run" do
    let!(:intake) { create :intake }

    before do
      allow(intake).to receive(:update)
    end

    context "no one" do
      it "does not error, just skips" do
        described_class.run

        expect(intake).not_to have_received(:update)
      end
    end

    context "primary" do
      let!(:user) do
        create(
          :user,
          intake: intake,
          is_spouse: false,
          consented_to_service: "yes",
          consented_to_service_at: DateTime.new(2020, 4, 22),
          consented_to_service_ip: nil,
          email_notification_opt_in: "unfilled",
          sms_notification_opt_in: "unfilled",
          email: "person@example.com",
          phone_number: "14155537865",
          first_name: "Cary",
          last_name: "Cabbage",
          birth_date: "1992-05-02",
          ssn: "333221111"
        )
      end

      it "transfers the existing column values" do
        described_class.run

        intake.reload
        expect(intake.primary_consented_to_service).to eq "yes"
        expect(intake.primary_consented_to_service_at).to eq DateTime.new(2020, 4, 22)
        expect(intake.primary_consented_to_service_ip).to be_nil
        expect(intake.email_address).to eq "person@example.com"
        expect(intake.primary_first_name).to eq "Cary"
        expect(intake.primary_last_name).to eq "Cabbage"
        expect(intake.primary_birth_date).to eq Date.new(1992, 5, 2)
        expect(intake.primary_last_four_ssn).to eq "1111"
        expect(intake.email_notification_opt_in).to eq "unfilled"
        expect(intake.sms_notification_opt_in).to eq "unfilled"
        expect(intake.phone_number).to eq "14155537865"
      end
    end

    context "spouse" do
      let!(:user) do
        create(
          :user,
          intake: intake,
          is_spouse: true,
          consented_to_service: "yes",
          consented_to_service_at: DateTime.new(2020, 4, 22),
          consented_to_service_ip: nil,
          email_notification_opt_in: "yes",
          sms_notification_opt_in: "yes",
          email: "person@example.com",
          phone_number: "14155537865",
          first_name: "Cassie",
          last_name: "Cabbage",
          birth_date: "1992-05-02",
          ssn: "333221111"
        )
      end

      it "transfers the existing column values" do
        described_class.run

        intake.reload
        expect(intake.spouse_consented_to_service).to eq "yes"
        expect(intake.spouse_consented_to_service_at).to eq DateTime.new(2020, 4, 22)
        expect(intake.spouse_consented_to_service_ip).to be_nil
        expect(intake.email_address).to be_nil
        expect(intake.spouse_first_name).to eq "Cassie"
        expect(intake.spouse_last_name).to eq "Cabbage"
        expect(intake.spouse_birth_date).to eq Date.new(1992, 5, 2)
        expect(intake.spouse_last_four_ssn).to eq "1111"
        expect(intake.email_notification_opt_in).to eq "unfilled"
        expect(intake.sms_notification_opt_in).to eq "unfilled"
        expect(intake.phone_number).to be_nil
      end
    end
  end
end
