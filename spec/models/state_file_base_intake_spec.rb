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
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('id_ernest_hoh')
      json = StateFile::DirectFileApiResponseSampleService.new.read_json('id_ernest_hoh')
      intake = create(:minimal_state_file_id_intake, raw_direct_file_data: xml, raw_direct_file_intake_data: json)
      expect(intake.dependents).to be_blank
      intake.synchronize_df_dependents_to_database

      expect(intake.dependents.first.relationship).to eq "grandParent"
      expect(intake.dependents.count).to eq 3
    end

    it "raises error if xml dependent is not found in JSON" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('id_ernest_hoh')
      json = StateFile::DirectFileApiResponseSampleService.new.read_json('id_ernest_hoh')
      intake = create(:minimal_state_file_id_intake, raw_direct_file_data: xml, raw_direct_file_intake_data: json)

      expect(intake.dependents).to be_blank
      # need to add dependents to the db first to get the dependent id for error message checking
      intake.synchronize_df_dependents_to_database

      expect(intake.dependents.length).to eq(3)
      allow(intake.direct_file_json_data).to receive(:find_matching_json_dependent).and_return(nil)
      expect { intake.synchronize_df_dependents_to_database }.to raise_error(StateFileBaseIntake::SynchronizeError, "Could not find matching dependent #{intake.dependents.first.id} with #{intake.state_name} intake id: #{intake.id}")
    end
  end

  describe "#synchronize_df_1099_rs_to_database" do
    it "reads in 1099Rs and adds all of them to the database" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('az_alexis_hoh_w2_and_1099')
      intake = create(:minimal_state_file_az_intake, raw_direct_file_data: xml)
      expect(intake.state_file1099_rs).to be_blank
      intake.synchronize_df_1099_rs_to_database

      expect(intake.state_file1099_rs.first.state_tax_withheld_amount).to eq 10
      expect(intake.state_file1099_rs.count).to eq 1
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
      expect(intake.direct_file_json_data.primary_filer.first_name).to eq('Lana')
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

  describe "#calculate_age" do
    let(:intake) { create :state_file_az_intake, primary_birth_date: dob }
    let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 10), 1, 1) }

    context "when following federal guidelines" do
      context "when calculating age for benefit one ages into" do
        it "includes Jan 1st b-days for the past tax year" do
          expect(intake.calculate_age(inclusive_of_jan_1: true, dob: dob)).to eq 11
        end
      end

      context "when calculating age for benefits one ages out of" do
        it "doesn't include Jan 1st for the past tax year" do
          expect(intake.calculate_age(inclusive_of_jan_1: false, dob: dob)).to eq 10
        end
      end
    end
  end
end