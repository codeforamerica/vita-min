require "rails_helper"

describe StateFileBaseIntake do
  describe "#synchronize_df_dependents_to_database" do
    it "reads in dependents and adds all of them to the database" do
      xml = StateFile::XmlReturnSampleService.new.read('ny_five_dependents')
      intake = create(:minimal_state_file_az_intake, raw_direct_file_data: xml)
      expect(intake.dependents).to be_blank
      intake.synchronize_df_dependents_to_database

      expect(intake.dependents.count).to eq 5
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

    context "when Maryland intake" do
      let(:intake) { create :state_file_md_intake, primary_birth_date: dob }
      it "doesn't include Jan 1st in the past tax year" do
        expect(intake.calculate_age(inclusive_of_jan_1: true, dob: dob)).to eq 10
        expect(intake.calculate_age(inclusive_of_jan_1: false, dob: dob)).to eq 10
      end
    end
  end
end