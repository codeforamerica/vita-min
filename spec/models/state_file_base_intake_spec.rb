require "rails_helper"

describe StateFileBaseIntake do
  describe "#has_verified_contact_info scope" do
    context "when there is an intake with a phone_number and phone_number_verified_at is present" do
      let!(:intake) { create(:state_file_az_intake, phone_number: "+14155551212", phone_number_verified_at: Time.now) }
      it "includes the intake in the scope" do
        expect(StateFileAzIntake.has_verified_contact_info).to include(intake)
      end
    end

    context "when there is an intake with a email_address and email_address_verified_at is present" do
      let!(:intake) { create(:state_file_az_intake, email_address: "email@example.com", email_address_verified_at: Time.now) }
      it "includes the intake in the scope" do
        expect(StateFileAzIntake.has_verified_contact_info).to include(intake)
      end
    end

    context "when there is are intake that contact methods are not verified" do
      let!(:phone_intake) { create(:state_file_az_intake, email_address: "email@example.com", email_address_verified_at: nil) }
      let!(:email_intake) { create(:state_file_az_intake, phone_number: "+14155551212", phone_number_verified_at: nil) }
      it "excludes the intake in the scope" do
        expect(StateFileAzIntake.has_verified_contact_info).not_to include(phone_intake, email_intake)
      end
    end
  end

  describe "state_code" do
    context ".state_code" do
      it "finds the right state code from the state information service" do
        expect(StateFileAzIntake.state_code).to eq "az"
      end
    end

    context "#state_code" do
      it "delegates to the instance method from the class method" do
        intake = create(:state_file_az_intake)
        expect(intake.state_code).to eq "az"
      end
    end
  end

  describe "#increment_failed_attempts" do
    let!(:intake) { create :state_file_az_intake, failed_attempts: 2 }
    it "locks access when failed attempts is incremented to 3" do
      expect(intake.access_locked?).to eq(false)

      intake.increment_failed_attempts

      expect(intake.access_locked?).to eq(true)
    end
  end

  describe "#unlock_for_login!" do
    let!(:intake) { create :state_file_az_intake, failed_attempts: 2, locked_at: 31.minutes.ago }

    before do
      allow(intake).to receive(:access_locked?).and_return(access_locked)
    end

    context "when access locked" do
      let(:access_locked) { true }

      it "should not reset failed_attempts and not clear out locked_at" do
        intake.unlock_for_login!
        expect(intake.failed_attempts).to eq(2)
        expect(intake.locked_at).to be_present
      end
    end

    context "when access not locked" do
      let(:access_locked) { false }

      it "should reset failed_attempts and clear out locked_at" do
        intake.unlock_for_login!
        expect(intake.failed_attempts).to eq(0)
        expect(intake.locked_at).to be_nil
      end

      context "when locked_at is nil" do
        before do
          intake.update(locked_at: nil)
        end

        it "should not reset failed_attempts and locked_at should remain nil" do
          intake.unlock_for_login!
          expect(intake.failed_attempts).to eq(2)
          expect(intake.locked_at).to be_nil
        end
      end
    end
  end

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
      expect(intake.state_file1099_rs.first.recipient_address_line1).to eq "200 Neptune Street"
      expect(intake.state_file1099_rs.first.recipient_city_name).to eq "Flagstaff"
      expect(intake.state_file1099_rs.first.recipient_state_code).to eq "AZ"
      expect(intake.state_file1099_rs.first.recipient_zip).to eq "86001"
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

    context "when W2 StateWagesAmt greater than database max of 10^10" do
      it "sets state_wages_amount to maximum $9,999,999,999.99" do
        intake = create(:state_file_nj_intake, :df_data_irs_test_box_16_large)
        intake.synchronize_df_w2s_to_database
        w2 = intake.state_file_w2s.first
        expect(w2.state_wages_amount).to eq 9_999_999_999.99
      end
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

    context "step is retirement_income" do
      let(:current_step) { "/en/questions/retirement-income" }

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
    %w[az md nc].each do |state_code|
      let(:intake) { create "state_file_#{state_code}_intake".to_sym }
      let!(:eligible_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 200) }
      let!(:ineligible_1099r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }

      it "should only return the 1099R with taxable_amount" do
        expect(intake.eligible_1099rs).to contain_exactly(eligible_1099r)
      end
    end
  end

  describe "#calculate_date_electronic_withdrawal" do
    let(:state_code) { "az" }
    let(:date_electronic_withdrawal) { intake.date_electronic_withdrawal }
    let(:intake) { create(:state_file_az_owed_intake) }
    let(:timezone) { StateFile::StateInformationService.timezone(state_code) }
    let(:payment_deadline_date) { StateFile::StateInformationService.payment_deadline_date(state_code) }
    let(:filing_year) { MultiTenantService.new(:statefile).current_tax_year }

    context "when submitted before payment deadline" do
      let(:current_time) { payment_deadline_date - 1.day }

      it "returns the user selected date" do
        result = intake.calculate_date_electronic_withdrawal(current_time: current_time)
        expect(result).to eq(date_electronic_withdrawal)
      end
    end

    context "when submitted after payment deadline" do
      let(:current_time) { payment_deadline_date + 1.day }

      it "returns the current time's date in the appropriate timezone" do
        result = intake.calculate_date_electronic_withdrawal(current_time: current_time)
        expect(result).to eq(current_time.in_time_zone(timezone).to_date)
      end
    end

    context "when submitted exactly on payment deadline" do
      let(:current_time) { payment_deadline_date }

      it "returns the current time's date in the appropriate timezone" do
        result = intake.calculate_date_electronic_withdrawal(current_time: current_time)
        expect(result).to eq(current_time.in_time_zone(timezone).to_date)
      end
    end

    context "with different timezone" do
      let(:state_code) { "md" }
      let(:timezone) { "America/New_York" }
      let(:current_time) { payment_deadline_date + 1.day }

      it "returns the current time's date in the correct timezone" do
        result = intake.calculate_date_electronic_withdrawal(current_time: current_time)
        expect(result).to eq(current_time.in_time_zone(timezone).to_date)
      end
    end
  end

  describe ".selected_intakes_for_deadline_reminder_notifications" do
    let!(:az_intake_with_email_notifications_and_df_import) {
      create :state_file_az_intake,
             df_data_imported_at: 2.minutes.ago,
             email_address: 'test@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    }
    let!(:az_intake_with_email_notifications_without_df_import) {
      create :state_file_az_intake,
             df_data_imported_at: nil,
             email_address: 'test@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    }
    let!(:az_intake_with_text_notifications_and_df_import) {
      create :state_file_az_intake,
             df_data_imported_at: 2.minutes.ago,
             phone_number: "+15551115511",
             sms_notification_opt_in: 1,
             phone_number_verified_at: 5.minutes.ago
    }
    let!(:az_intake_with_unverified_text_notifications_and_df_import) {
      create :state_file_az_intake,
             df_data_imported_at: 2.minutes.ago,
             phone_number: "+15551115511",
             sms_notification_opt_in: "yes",
             email_address: 'test@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: "no"
    }
    let!(:az_intake_submitted) {
      create :state_file_az_intake,
             df_data_imported_at: 2.minutes.ago,
             email_address: 'test+01@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    }
    let!(:efile_submission) { create :efile_submission, :for_state, data_source: az_intake_submitted }
    let!(:az_intake_has_received_reminder) {
      create :state_file_az_intake, email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             df_data_imported_at: 2.minutes.ago,
             message_tracker: { "messages.state_file.finish_return" => (Time.now - 2.hours).utc.to_s }
    }
    let!(:az_intake_received_reminder_not_recent) {
      create :state_file_az_intake, email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             df_data_imported_at: 2.minutes.ago,
             message_tracker: { "messages.state_file.finish_return" => (Time.now - 28.hours).utc.to_s }
    }
    let!(:az_intake_has_disqualifying_df_data) {
      create :state_file_az_intake,
             filing_status: :married_filing_separately,
             email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             df_data_imported_at: 2.minutes.ago
    }
    let!(:az_intake_received_reminder_not_recent_disqualifying_df_data) {
      create :state_file_az_intake, email_address: "test@example.com",
             filing_status: :married_filing_separately,
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             df_data_imported_at: 2.minutes.ago,
             message_tracker: { "messages.state_file.finish_return" => (Time.now - 28.hours).utc.to_s }
    }
    let!(:az_intake_submitted_ssn_duplicate) {
      create :state_file_az_intake,
             email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             phone_number: nil,
             df_data_imported_at: 2.minutes.ago,
             hashed_ssn: "111443333",
             message_tracker: { "messages.state_file.welcome" => "2024-11-06 21:14:49 UTC"}
    }
    let!(:az_intake_submitted_ssn_duplicate_1) {
      create :state_file_az_intake,
             email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             phone_number: nil,
             df_data_imported_at: 2.minutes.ago,
             hashed_ssn: "111443333",
             message_tracker: { "messages.state_file.welcome" => "2024-11-06 23:14:49 UTC"}
    }
    let!(:efile_submission_for_duplicate) { create :efile_submission, :for_state, data_source: az_intake_submitted_ssn_duplicate }

    before do
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:prevent_duplicate_ssn_messaging).and_return(true)
    end

    it "returns intakes with verified contact info, valid df data, and without recent finish return messages or efile submissions or duplicate (same hashed_ssn) intake with efile submission" do
      results = StateFileAzIntake.selected_intakes_for_deadline_reminder_notifications
      intakes_to_message = [
        az_intake_with_email_notifications_and_df_import,
        az_intake_with_text_notifications_and_df_import,
        az_intake_with_unverified_text_notifications_and_df_import,
        az_intake_received_reminder_not_recent
      ]
      expect(results).to match_array(intakes_to_message)
    end
  end

  describe ".selected_intakes_for_deadline_reminder_soon_notifications" do
    let!(:az_intake_with_email_notifications_and_df_import) {
      create :state_file_az_intake,
             df_data_imported_at: 2.minutes.ago,
             email_address: 'test@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    }
    let!(:az_intake_with_email_notifications_and_df_import_from_last_year) {
      create :state_file_az_intake,
             df_data_imported_at: 2.minutes.ago,
             email_address: 'test@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1,
             created_at: (1.year.ago)
    }
    let!(:az_intake_with_email_notifications_without_df_import) {
      create :state_file_az_intake,
             df_data_imported_at: nil,
             email_address: 'test@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    }
    let!(:az_intake_with_text_notifications_and_df_import) {
      create :state_file_az_intake,
             df_data_imported_at: 2.minutes.ago,
             phone_number: "+15551115511",
             sms_notification_opt_in: 1,
             phone_number_verified_at: 5.minutes.ago
    }
    let!(:az_intake_with_unverified_text_notifications_and_df_import) {
      create :state_file_az_intake,
             df_data_imported_at: 2.minutes.ago,
             phone_number: "+15551115511",
             sms_notification_opt_in: "yes",
             email_address: 'test@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: "no"
    }
    let!(:az_intake_submitted) {
      create :state_file_az_intake,
             df_data_imported_at: 2.minutes.ago,
             email_address: 'test+01@example.com',
             email_address_verified_at: 5.minutes.ago,
             email_notification_opt_in: 1
    }
    let!(:efile_submission) { create :efile_submission, :for_state, data_source: az_intake_submitted }
    let!(:az_intake_has_disqualifying_df_data) {
      create :state_file_az_intake,
             filing_status: :married_filing_separately,
             email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             df_data_imported_at: 2.minutes.ago
    }
    let!(:az_intake_submitted_ssn_duplicate) {
      create :state_file_az_intake,
             email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             phone_number: nil,
             df_data_imported_at: 2.minutes.ago,
             hashed_ssn: "111443333"
    }
    let!(:az_intake_submitted_ssn_duplicate_1) {
      create :state_file_az_intake,
             email_address: "test@example.com",
             email_address_verified_at: 1.hour.ago,
             email_notification_opt_in: 1,
             phone_number: nil,
             df_data_imported_at: 2.minutes.ago,
             hashed_ssn: "111443333"
    }
    let!(:efile_submission_for_duplicate) { create :efile_submission, :for_state, data_source: az_intake_submitted_ssn_duplicate }

    before do
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:prevent_duplicate_ssn_messaging).and_return(true)
    end

    it "returns intakes with verified contact info, valid df data, and without recent finish return messages or efile submissions or duplicate (same hashed_ssn) intake with efile submission" do
      results = StateFileAzIntake.selected_intakes_for_deadline_reminder_soon_notifications
      intakes_to_message = [
        az_intake_with_email_notifications_and_df_import,
        az_intake_with_text_notifications_and_df_import,
        az_intake_with_unverified_text_notifications_and_df_import,
      ]
      expect(results).to match_array(intakes_to_message)
    end
  end

  describe "#should_be_sent_reminder?" do
    let(:message_tracker) { nil }
    let(:intake) { create :state_file_az_intake, message_tracker: message_tracker }

    context "without message tracker data or disqualifying not present" do
      it "returns true" do
        expect(intake.should_be_sent_reminder?).to eq(true)
      end
    end

    context "with finish return email recently" do
      let(:message_tracker) { { "messages.state_file.finish_return" => (Time.now - 2.hours).utc.to_s } }
      it "returns false" do
        expect(intake.should_be_sent_reminder?).to eq(false)
      end
    end

    context "with disqualifying_df_data_reason" do
      it "returns false" do
        allow_any_instance_of(StateFileAzIntake).to receive(:disqualifying_df_data_reason).and_return :has_out_of_state_w2
        expect(intake.should_be_sent_reminder?).to eq(false)
      end
    end
  end

  describe "#other_intake_with_same_ssn_has_submission?" do
    let(:intake) { create :state_file_nc_intake, hashed_ssn: hashed_ssn }

    context "prevent_duplicate_ssn_messaging flipper enabled" do
      before do
        allow(Flipper).to receive(:enabled?).and_call_original
        allow(Flipper).to receive(:enabled?).with(:prevent_duplicate_ssn_messaging).and_return(true)
      end

      context "has no hashed_ssn" do
        let(:hashed_ssn) { nil }
        it "has no hashed_ssn" do
          expect(intake.other_intake_with_same_ssn_has_submission?).to be_falsey
        end
      end

      context "has hashed_ssn" do
        let(:hashed_ssn) { SsnHashingService.hash("333001298") }

        context "has a submission" do
          before do
            EfileSubmission.create(data_source: intake)
          end

          context "matching intake does not have efile_submission" do
            let(:matching_intake) { create :state_file_nc_intake, hashed_ssn: hashed_ssn }

            it "is false (does not consider itself as the other intake)" do
              expect(intake.other_intake_with_same_ssn_has_submission?).to be_falsey
            end
          end
        end

        context "has another intake with matching ssn" do
          context "matching intake has efile_submission" do
            before do
              EfileSubmission.create(data_source: matching_intake)
            end

            context "in same state" do
              let(:matching_intake) { create :state_file_nc_intake, hashed_ssn: hashed_ssn }

              it "is true" do
                expect(intake.other_intake_with_same_ssn_has_submission?).to be_truthy
              end
            end

            context "in another state" do
              let(:matching_intake) { create :state_file_az_intake, hashed_ssn: hashed_ssn }

              it "is true" do
                expect(intake.other_intake_with_same_ssn_has_submission?).to be_truthy
              end
            end

            context "in NY state" do
              let(:matching_intake) { create :state_file_ny_intake, hashed_ssn: hashed_ssn }

              it "is false" do
                expect(intake.other_intake_with_same_ssn_has_submission?).to be_falsey
              end
            end
          end

          context "matching intake has no efile_submission" do
            let!(:matching_intake) { create :state_file_nc_intake, hashed_ssn: hashed_ssn }

            it "is true" do
              expect(intake.other_intake_with_same_ssn_has_submission?).to be_falsey
            end
          end
        end

        context "has no intakes with matching ssn" do
          let!(:non_matching_intake) { create :state_file_nc_intake, hashed_ssn:  SsnHashingService.hash("333009999")}

          it "is false" do
            expect(intake.other_intake_with_same_ssn_has_submission?).to be_falsey
          end
        end
      end
    end

    context "prevent_duplicate_ssn_messaging flipper disabled" do
      let(:hashed_ssn) { SsnHashingService.hash("333001298") }

      before do
        allow(Flipper).to receive(:enabled?).and_call_original
        allow(Flipper).to receive(:enabled?).with(:prevent_duplicate_ssn_messaging).and_return(false)
        EfileSubmission.create(data_source: matching_intake)
      end

      context "has matching intake with same hashed_ssn" do
        let(:matching_intake) { create :state_file_nc_intake, hashed_ssn: hashed_ssn }

        it "is false" do
          expect(intake.other_intake_with_same_ssn_has_submission?).to be_falsey
        end
      end
    end
  end

  describe "#no_prior_message_history_of scope" do
    let!(:intake_with_finish_return_message) { create(:state_file_az_intake, message_tracker: { "messages.state_file.finish_return" => "2024-11-06 21:14:49 UTC" }) }
    let!(:intake_with_welcome_message) { create(:state_file_az_intake, message_tracker: { "messages.state_file.welcome" => "2024-11-06 21:14:49 UTC" }) }
    let!(:intake_with_no_messages) { create(:state_file_az_intake, message_tracker: {}) }

    it "includes and excludes the correct intakes" do
      expect(StateFileAzIntake.no_prior_message_history_of('az', StateFile::AutomatedMessage::FinishReturn.name)).not_to include(intake_with_finish_return_message)
      expect(StateFileAzIntake.no_prior_message_history_of('az', StateFile::AutomatedMessage::FinishReturn.name)).to include(intake_with_welcome_message, intake_with_no_messages)
      expect(StateFileAzIntake.no_prior_message_history_of('az', StateFile::AutomatedMessage::Welcome.name)).not_to include(intake_with_welcome_message)
    end
  end
end
