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
      expect(intake.dependents.last.qualifying_child).to eq nil
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

    it "saves the status of qualifying children" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('id_john_mfj_8_deps')
      json = StateFile::DirectFileApiResponseSampleService.new.read_json('id_john_mfj_8_deps')
      intake = create(:minimal_state_file_id_intake, raw_direct_file_data: xml, raw_direct_file_intake_data: json)
      intake.synchronize_df_dependents_to_database

      expect(intake.dependents.count(&:qualifying_child?)).to eq 2
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

  describe "#synchronize_df_w2s_to_database" do
    it "reads in w2s and adds all of them to the database" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('az_alexis_hoh_w2_and_1099')
      intake = create(:minimal_state_file_az_intake, raw_direct_file_data: xml)
      expect(intake.state_file_w2s).to be_blank
      intake.synchronize_df_w2s_to_database

      expect(intake.state_file_w2s.count).to eq 1
      w2 = intake.state_file_w2s.first

      expect(w2.employer_name).to eq "Rose Apothecary"
      expect(w2.employee_name).to eq "Alexis Rose"
      expect(w2.employee_ssn).to eq "400000003"
      expect(w2.employer_state_id_num).to eq "12345"
      expect(w2.local_income_tax_amount).to eq 1000
      expect(w2.local_wages_and_tips_amount).to eq 1350
      expect(w2.locality_nm).to eq "SOMECITY"
      expect(w2.state_income_tax_amount).to eq 500
      expect(w2.state_wages_amount).to eq 35000
    end

    it "reads in w2s and removes dash/hyphen from employer_state_id_num" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r')
      intake = create(:minimal_state_file_id_intake, raw_direct_file_data: xml)
      expect(intake.state_file_w2s).to be_blank
      intake.synchronize_df_w2s_to_database

      expect(intake.state_file_w2s.count).to eq 2
      w2 = intake.state_file_w2s.first

      expect(w2.employer_state_id_num).to eq "000000005"
    end

    it "adds box 14 fields" do
      intake = create(:state_file_nj_intake, :df_data_box_14)
      intake.synchronize_df_w2s_to_database
      expect(intake.state_file_w2s.count).to eq 1
      w2 = intake.state_file_w2s.first

      expect(w2.box14_fli).to eq 550.00
      expect(w2.box14_stpickup).to eq 250.00
      expect(w2.box14_ui_hc_wd).to eq 450.00
      expect(w2.box14_ui_wf_swf).to eq 350.00
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
    let(:dob) { Date.new((MultiTenantService.statefile.current_tax_year - 10), 1, 1) }

    context "when calculating age inclusive of Jan 1" do
      it "Jan 1 birthdays are older at the end of this tax year" do
        expect(intake.calculate_age(dob, inclusive_of_jan_1: true)).to eq 11
      end
    end

    context "when calculating age not inclusive of Jan 1" do
      it "Jan 1 birthdays are not older at the end of this tax year" do
        expect(intake.calculate_age(dob, inclusive_of_jan_1: false)).to eq 10
      end
    end
  end
end