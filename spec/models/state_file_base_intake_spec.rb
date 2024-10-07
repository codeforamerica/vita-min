require "rails_helper"

describe StateFileBaseIntake do
  describe "#synchronize_filers_to_database" do
    context "when filing status is single" do
      let(:intake) { create(:state_file_id_intake, :single_filer_with_json) }

      it "updates primary filer information" do
        intake.synchronize_filers_to_database

        expect(intake.primary_first_name).to eq("Lana")
        expect(intake.primary_middle_initial).to be_nil
        expect(intake.primary_last_name).to eq("Turner")
        expect(intake.primary_birth_date).to eq(Date.parse("1980-01-01"))

        expect(intake.spouse_first_name).to be_nil
        expect(intake.spouse_middle_initial).to be_nil
        expect(intake.spouse_last_name).to be_nil
        expect(intake.spouse_birth_date).to be_nil
      end
    end

    context "when filing status is married filing jointly" do
      let(:intake) { create(:state_file_id_intake, :mfj_filer_with_json) }

      it "updates both primary and spouse filer information" do
        intake.synchronize_filers_to_database

        expect(intake.primary_first_name).to eq("Paul")
        expect(intake.primary_middle_initial).to eq("S")
        expect(intake.primary_last_name).to eq("Revere")
        expect(intake.primary_birth_date).to eq(Date.parse("1980-01-01"))

        expect(intake.spouse_first_name).to eq("Sydney")
        expect(intake.spouse_middle_initial).to be_nil
        expect(intake.spouse_last_name).to eq("Revere")
        expect(intake.spouse_birth_date).to eq(Date.parse("1980-01-01"))
      end
    end
  end

  describe "#synchronize_df_dependents_to_database" do
    it "reads in dependents and adds all of them to the database" do
      xml = StateFile::XmlReturnSampleService.new.read('id_ernest_hoh')
      json = StateFile::JsonReturnSampleService.new.read('id_ernest_hoh')
      intake = create(:minimal_state_file_id_intake, raw_direct_file_data: xml, raw_direct_file_intake_data: json)
      expect(intake.dependents).to be_blank
      intake.synchronize_df_dependents_to_database

      expect(intake.dependents.first.relationship).to eq "Grandparent"
      expect(intake.dependents.count).to eq 3
    end
  end

  describe "#timedout?" do
    let!(:intake) { create :state_file_az_intake }
    let!(:efile_submission) { create :efile_submission, data_source_id: intake.id, data_source_type: "StateFileAzIntake" }

    context "when timed out" do
      let!(:intake) { create :state_file_az_intake }
      it "actually times out" do
        # Confusingly, timedout?(15.minutes.ago) actually means: 'With the last accessed at of the
        # timestamp given, are we now timed out?'
        expect(intake.timedout?(14.minutes.ago)).to eq false
        expect(intake.timedout?(15.minutes.ago)).to eq true
        expect(intake.timedout?(16.minutes.ago)).to eq true
      end
    end
  end

  describe "#direct_file_json_data" do
    let(:intake) { create(:state_file_id_intake, :single_filer_with_json) }
    it "returns the json data from Direct File that contains personal information" do
      expect(intake.direct_file_json_data.primary_first_name).to eq('Lana')
    end
  end

  describe '.opted_out_state_file_intakes' do
    let!(:email) { 'email@test.com' }
    let!(:intake) { create :state_file_az_intake, email_address: email, unsubscribed_from_email: true }

    context 'when is a FYST email' do
      it 'returns the intakes' do
        expect(StateFileBaseIntake.opted_out_state_file_intakes(email).length).to eq 1
      end
    end

    context 'when is NOT a FYST email' do
      it 'returns empty' do
        expect(StateFileBaseIntake.opted_out_state_file_intakes('another_email@test.com')).to be_empty
      end
    end
  end

  describe "#tax_calculator" do
    it "returns an instance of the calculator class from the information service" do
      intake = create(:state_file_az_intake)
      expect(intake.tax_calculator).to be_an_instance_of(Efile::Az::Az140Calculator)
    end
  end
end
