# == Schema Information
#
# Table name: efile_submission_dependents
#
#  id                  :bigint           not null, primary key
#  age_during_tax_year :integer
#  qualifying_child    :boolean
#  qualifying_ctc      :boolean
#  qualifying_eitc     :boolean
#  qualifying_relative :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  dependent_id        :bigint
#  efile_submission_id :bigint
#
# Indexes
#
#  index_efile_submission_dependents_on_dependent_id         (dependent_id)
#  index_efile_submission_dependents_on_efile_submission_id  (efile_submission_id)
#
require "rails_helper"

describe EfileSubmissionDependent do
  let(:submission) { create :efile_submission }
  let(:dependent) { create :dependent }

  describe '.create_qualifying_dependent' do
    let(:results) do
      {
          qualifying_child: true,
          qualifying_relative: false,
          qualifying_ctc: false,
      }
    end

    before do
      allow_any_instance_of(Efile::DependentEligibility::Eligibility).to receive(:test_results).and_return results
    end

    context "when the submission and dependent are not already associated through the intake" do
      it "raises an error" do
        expect {
          EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
        }.to raise_error RuntimeError
      end
    end

    context "when the submission and dependent are associated through their intake" do
      let(:client) { create :client_with_ctc_intake_and_return }
      let(:submission) { create :efile_submission, tax_return: client.tax_returns.first }
      let(:dependent) { create :dependent, intake: client.intake }
      let(:eligibility_double) { double(Efile::DependentEligibility::Eligibility) }

      before do
        allow(Efile::DependentEligibility::Eligibility).to receive(:new).and_return(eligibility_double)
        allow(eligibility_double).to receive(:qualifying_child?).and_return true
        allow(eligibility_double).to receive(:qualifying_ctc?).and_return false
        allow(eligibility_double).to receive(:qualifying_eitc?).and_return false
        allow(eligibility_double).to receive(:qualifying_relative?).and_return false
        allow(eligibility_double).to receive(:age).and_return 5
      end

      it "delegates some attributes to the original dependent, even if soft-deleted" do
        efile_submission_dependent = EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
        expect(efile_submission_dependent.first_name).to eq(dependent.first_name)

        dependent.touch(:soft_deleted_at)
        expect(efile_submission_dependent.reload.first_name).to eq(dependent.reload.first_name)
      end

      it "calculates eligibility" do
        EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
        expect(eligibility_double).to have_received(:qualifying_eitc?).exactly(1).times
        expect(eligibility_double).to have_received(:qualifying_ctc?).exactly(2).times
        expect(eligibility_double).to have_received(:qualifying_child?).exactly(2).times
        expect(eligibility_double).to have_received(:qualifying_relative?).exactly(2).times
      end

      context "when the tested dependent is eligible for something" do
        it "creates an EfileSubmissionDependent object" do
          expect {
            EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
          }.to change(EfileSubmissionDependent, :count).by(1)
          object = EfileSubmissionDependent.last

          expect(object.age_during_tax_year).to eq 5
          expect(object.qualifying_child).to eq true
          expect(object.qualifying_ctc).to eq false
          expect(object.qualifying_relative).to eq false
        end
      end

      context "when the tested dependent is not eligible for anything" do
        before do
          allow(eligibility_double).to receive(:qualifying_child?).and_return false
          allow(eligibility_double).to receive(:qualifying_ctc?).and_return false
          allow(eligibility_double).to receive(:qualifying_relative?).and_return false
          allow(eligibility_double).to receive(:age).and_return 5
        end
        it "does not create an EfileSubmissionDependent object" do
          expect {
            EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
          }.not_to change(EfileSubmissionDependent, :count)
        end
      end
    end
  end

  describe "#schedule_eic_4a?" do
    let(:primary_birth_date) { 50.years.ago }
    let(:spouse_birth_date) { 50.years.ago }
    let(:filing_status) { "single" }

    let(:tax_return) { build :tax_return, year: DateTime.now.year,filing_status: filing_status }
    let!(:client) { create :client, intake: build(:ctc_intake, primary_birth_date: primary_birth_date, spouse_birth_date: spouse_birth_date), tax_returns: [tax_return] }
    let(:intake) { client.intake }
    let!(:submission) { create :efile_submission, tax_return: tax_return }
    let(:dependent) { create :qualifying_child, intake: submission.intake, full_time_student: full_time_student, birth_date: birth_date }
    let!(:efile_submission_dependent) { EfileSubmissionDependent.create_qualifying_dependent(submission, dependent) }
    let(:full_time_student) { "yes" }

    context "when the dependent is between 19 and 24 and a full time student" do
      let(:birth_date) { 22.years.ago }
      let(:full_time_student) { "yes" }

      context "when the filing status is single" do
        let(:filing_status) { "single" }

        context "when the dependent is younger than the primary" do
          let(:primary_birth_date) { 50.years.ago }

          it "they meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq true
          end
        end

        context "when the dependent is older than the primary" do
          let(:dependent) { create :qualifying_relative, intake: submission.intake, full_time_student: full_time_student, birth_date: birth_date }
          let(:primary_birth_date) { 21.years.ago }

          it "they do not meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq false
          end
        end
      end

      context "when the filing status is mfj" do
        let(:dependent) { create :qualifying_relative, intake: submission.intake, full_time_student: full_time_student, birth_date: birth_date }
        let(:filing_status) { "married_filing_jointly" }

        context "when the dependent is younger than the primary but not the spouse" do
          let(:primary_birth_date) { 26.years.ago }
          let(:spouse_birth_date) { 21.years.ago }

          it "they meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq true
          end
        end

        context "when the dependent is younger than the spouse but not the primary" do
          let(:primary_birth_date) { 21.years.ago }
          let(:spouse_birth_date) { 26.years.ago }

          it "they meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq true
          end
        end

        context "when the dependent is older than the spouse and the primary" do
          let(:primary_birth_date) { 21.years.ago }
          let(:spouse_birth_date) { 21.years.ago }

          it "they do not meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq false
          end
        end
      end
    end

    context "when the dependent is over 24" do
      let(:dependent) { create :qualifying_relative, intake: submission.intake, full_time_student: full_time_student, birth_date: birth_date }
      let(:birth_date) { 25.years.ago }
      let(:full_time_student) { "yes" }

      it "they do not meet the conditions for checkbox 4a" do
        expect(efile_submission_dependent.schedule_eic_4a?).to eq false
      end
    end

    context "when the dependent is under 19" do
      let(:birth_date) { 18.years.ago }

      it "they do not meet the conditions to fill out question 4" do
        expect(efile_submission_dependent.skip_schedule_eic_question_4?).to be_truthy
        expect(efile_submission_dependent.schedule_eic_4a?).to be_falsey
      end
    end

    context "when the dependent is not a full time student" do
      let(:dependent) { create :qualifying_relative, intake: submission.intake, full_time_student: full_time_student, birth_date: birth_date }
      let(:birth_date) { 22.years.ago }
      let(:full_time_student) { "no" }

      it "they do not meet the conditions for checkbox 4a" do
        expect(efile_submission_dependent.schedule_eic_4a?).to eq false
      end
    end
  end

  describe "#schedule_eic_4b?" do
    let(:tax_return) { build :tax_return, year: DateTime.now.year }
    let!(:client) { create :client, intake: build(:ctc_intake), tax_returns: [tax_return] }
    let(:intake) { client.intake }
    let!(:submission) { create :efile_submission, tax_return: tax_return }
    let(:dependent) { create :qualifying_child, intake: submission.intake, birth_date: birth_date, permanently_totally_disabled: permanently_totally_disabled }
    let!(:efile_submission_dependent) { EfileSubmissionDependent.create_qualifying_dependent(submission, dependent) }
    let(:birth_date) { 19.years.ago }

    context "when we skipped question 4a (dependent was less than 19 and not younger than filers)" do
      let(:birth_date) { 16.years.ago }
      let(:permanently_totally_disabled) { "yes" }

      it "is truthy" do
        expect(efile_submission_dependent.schedule_eic_4b?).to eq true
      end
    end

    context "when the dependent was disabled" do
      let(:permanently_totally_disabled) { "yes" }

      it "is true" do
        expect(efile_submission_dependent.schedule_eic_4b?).to eq true
      end
    end
  end
end
