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
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('id_estrada_donations')
      json = StateFile::DirectFileApiResponseSampleService.new.read_json('id_estrada_donations')
      intake = create(:minimal_state_file_id_intake, raw_direct_file_data: xml, raw_direct_file_intake_data: json)
      expect(intake.dependents).to be_blank
      intake.synchronize_df_dependents_to_database

      expect(intake.dependents.first&.relationship).to eq "childOfSibling"
      expect(intake.dependents.last.qualifying_child).to eq false
      expect(intake.dependents.count).to eq 4
    end

    it "raises error if xml dependent is not found in JSON" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('id_estrada_donations')
      json = StateFile::DirectFileApiResponseSampleService.new.read_json('id_estrada_donations')
      intake = create(:minimal_state_file_id_intake, raw_direct_file_data: xml, raw_direct_file_intake_data: json)

      expect(intake.dependents).to be_blank
      # need to add dependents to the db first to get the dependent id for error message checking
      intake.synchronize_df_dependents_to_database

      expect(intake.dependents.length).to eq(4)
      allow(intake.direct_file_json_data).to receive(:find_matching_json_dependent).and_return(nil)
      expect { intake.synchronize_df_dependents_to_database }.to raise_error(StateFileBaseIntake::SynchronizeError, "Could not find matching dependent #{intake.dependents.first.id} with #{intake.state_name} intake id: #{intake.id}")
    end

    it "saves the status of qualifying children" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('id_estrada_donations')
      json = StateFile::DirectFileApiResponseSampleService.new.read_json('id_estrada_donations')
      intake = create(:minimal_state_file_id_intake, raw_direct_file_data: xml, raw_direct_file_intake_data: json)
      intake.synchronize_df_dependents_to_database

      expect(intake.dependents.count(&:qualifying_child?)).to eq 3
    end
  end

  describe "#synchronize_df_1099_rs_to_database" do
    it "reads in 1099Rs and adds all of them to the database" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('az_tycho_single_with_1099r')
      intake = create(:minimal_state_file_az_intake, raw_direct_file_data: xml)
      expect(intake.state_file1099_rs).to be_blank
      intake.synchronize_df_1099_rs_to_database

      expect(intake.state_file1099_rs.first.state_tax_withheld_amount).to eq 50
      expect(intake.state_file1099_rs.count).to eq 1
    end
  end

  describe "#synchronize_df_w2s_to_database" do
    it "reads in w2s and adds all of them to the database" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('test_alexis_hoh_w2_and_1099')
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
      expect(w2.wages).to eq 35000
      expect(w2.employer_ein).to eq "234567891"
    end

    it "reads in w2s and removes dash/hyphen from employer_state_id_num" do
      xml = StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r')
      intake = create(:minimal_state_file_id_intake, raw_direct_file_data: xml)
      expect(intake.state_file_w2s).to be_blank
      intake.synchronize_df_w2s_to_database

      expect(intake.state_file_w2s.count).to eq 2
      w2 = intake.state_file_w2s.first

      expect(w2.employer_state_id_num).to eq "00-0000005"
    end

    it "adds box 14 fields" do
      intake = create(:state_file_nj_intake, :df_data_box_14)
      intake.synchronize_df_w2s_to_database
      expect(intake.state_file_w2s.count).to eq 2
      w2 = intake.state_file_w2s.first

      expect(w2.box14_fli).to eq 145.00
      expect(w2.box14_ui_hc_wd).to eq 140.00
      expect(w2.box14_ui_wf_swf).to eq 180.00
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

  describe "#validate_state_specific_w2_requirements" do
    let(:intake) { create :state_file_ny_intake }
    let(:w2) {
      create(:state_file_w2,
             employer_state_id_num: "001245788",
             employer_ein: '123445678',
             local_income_tax_amount: 200,
             local_wages_and_tips_amount: 8000,
             locality_nm: "NYC",
             state_file_intake: intake,
             state_income_tax_amount: 600,
             state_wages_amount: 8000,
             w2_index: 0
      )
    }

    it "allows state_wages_amount to be greater than w2.WagesAmt" do
      w2.state_wages_amount = 1000000
      intake.validate_state_specific_w2_requirements(w2)
      expect(w2).to be_valid(:state_file_edit)
      expect(w2.errors[:state_wages_amount]).not_to be_present
    end
  end

  describe "#controller_for_current_step" do
    let(:current_step) { "/en/questions/az-prior-last-names" }
    let(:intake) { create :state_file_az_intake, current_step: current_step }

    it "returns the correct controller" do
      expect(intake.controller_for_current_step).to eq StateFile::Questions::AzPriorLastNamesController
    end

    context "there are efile submissions" do
      let!(:efile_submission) { create :efile_submission, data_source: intake }

      it "returns the return status controller" do
        expect(intake.controller_for_current_step).to eq StateFile::Questions::ReturnStatusController
      end
    end

    context "current step throws an error" do
      let(:current_step) { "/en/questions/some-garbage" }

      it "returns the terms and conditions controller" do
        expect(intake.controller_for_current_step).to eq StateFile::Questions::TermsAndConditionsController
      end

      context "there is a hashed ssn" do
        it "returns the post data transfer controller" do
          intake.update(hashed_ssn: "123")
          expect(intake.controller_for_current_step).to eq StateFile::Questions::PostDataTransferController
        end
      end
    end

    context "step is w2" do
      let(:current_step) { "/en/questions/w2" }

      it "returns the income review controller" do
        expect(intake.controller_for_current_step).to eq StateFile::Questions::IncomeReviewController
      end
    end
  end

  describe "#sum_1099_r_followup_type_for_filer" do

    context "with 1099Rs" do
      let!(:intake) { create(:state_file_md_intake, :with_spouse) }
      let!(:state_file_1099_r_without_followup) {
        create(
          :state_file1099_r,
          taxable_amount: 1_000,
          recipient_ssn: intake.primary.ssn,
          intake: intake)
      }
      let!(:state_file_md1099_r_followup_with_military_service_for_primary_1) do
        create(
          :state_file_md1099_r_followup,
          service_type: "military",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_000, intake: intake, recipient_ssn: intake.primary.ssn)
        )
      end
      let!(:state_file_md1099_r_followup_with_military_service_for_primary_2) do
        create(
          :state_file_md1099_r_followup,
          service_type: "military",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_500, intake: intake, recipient_ssn: intake.primary.ssn)
        )
      end
      let!(:state_file_md1099_r_followup_with_military_service_for_spouse) do
        create(
          :state_file_md1099_r_followup,
          service_type: "military",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 2_000, intake: intake, recipient_ssn: intake.spouse.ssn)
        )
      end
      let!(:state_file_md1099_r_followup_without_military) do
        create(
          :state_file_md1099_r_followup,
          service_type: "none",
          state_file1099_r: create(:state_file1099_r, taxable_amount: 1_000, intake: intake, recipient_ssn: intake.spouse.ssn)
        )
      end

      it "totals the followup income" do
        expect(intake.sum_1099_r_followup_type_for_filer(:primary, :service_type_military?)).to eq(2_500)
        expect(intake.sum_1099_r_followup_type_for_filer(:spouse, :service_type_military?)).to eq(2_000)
      end
    end

    context "without 1099Rs" do
      let(:intake) { create(:state_file_md_intake) }
      it "returns 0" do
        expect(intake.sum_1099_r_followup_type_for_filer(:primary, :service_type_military?)).to eq(0)
        expect(intake.sum_1099_r_followup_type_for_filer(:spouse, :service_type_military?)).to eq(0)
      end
    end
  end

  describe "#eligible_1099rs" do
    %w[az md nc nj].each do |state_code|
      let(:intake) { create "state_file_#{state_code}_intake".to_sym }
      let!(:eligible_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 200) }
      let!(:ineligible_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }

      it "should only return the 1099R with taxable_amount" do
        expect(intake.eligible_1099rs).to contain_exactly(eligible_1099r)
      end
    end
  end
end