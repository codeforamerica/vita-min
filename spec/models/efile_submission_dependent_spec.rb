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
    let(:dependent) { create :dependent, full_time_student: full_time_student }
    let(:efile_submission_dependent) { create :efile_submission_dependent, dependent: dependent, age_during_tax_year: age_during_tax_year }

    before do
      efile_submission_dependent.efile_submission.tax_return.update(year: DateTime.now.year)
      efile_submission_dependent.intake.update(primary_birth_date: 50.years.ago)
      efile_submission_dependent.intake.update(spouse_birth_date: 50.years.ago)
    end

    context "when the dependent is between 19 and 24 and a full time student" do
      let(:age_during_tax_year) { 22 }
      let(:full_time_student) { "yes" }

      context "when the filing status is single" do
        before do
          submission.tax_return.update(filing_status: "single")
        end

        context "when the dependent is younger than the primary" do
          before do
            efile_submission_dependent.intake.update(primary_birth_date: 50.years.ago)
          end

          it "they meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq true
          end
        end

        context "when the dependent is older than the primary" do
          before do
            efile_submission_dependent.intake.update(primary_birth_date: 21.years.ago)
          end

          it "they do not meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq false
          end
        end
      end

      context "when the filing status is mfj" do
        before do
          efile_submission_dependent.efile_submission.tax_return.update(filing_status: "married_filing_jointly")
        end

        context "when the dependent is younger than the primary but not the spouse" do
          before do
            efile_submission_dependent.intake.update(primary_birth_date: 26.years.ago)
            efile_submission_dependent.intake.update(spouse_birth_date: 21.years.ago)
          end

          it "they meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq true
          end
        end

        context "when the dependent is younger than the spouse but not the primary" do
          before do
            efile_submission_dependent.intake.update(primary_birth_date: 21.years.ago)
            efile_submission_dependent.intake.update(spouse_birth_date: 26.years.ago)
          end

          it "they meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq true
          end
        end

        context "when the dependent is older than the spouse and the primary" do
          before do
            efile_submission_dependent.intake.update(primary_birth_date: 21.years.ago)
            efile_submission_dependent.intake.update(spouse_birth_date: 21.years.ago)
          end

          it "they do not meet the conditions for checkbox 4a" do
            expect(efile_submission_dependent.schedule_eic_4a?).to eq false
          end
        end
      end
    end

    context "when the dependent is over 24" do
      let(:age_during_tax_year) { 25 }
      let(:full_time_student) { "yes" }

      it "they do not meet the conditions for checkbox 4a" do
        expect(efile_submission_dependent.schedule_eic_4a?).to eq false
      end
    end

    context "when the dependent is under 19" do
      let(:age_during_tax_year) { 18 }
      let(:full_time_student) { "yes" }

      it "they do not meet the conditions for checkbox 4a" do
        expect(efile_submission_dependent.schedule_eic_4a?).to eq false
      end
    end

    context "when the dependent is not a full time student" do
      let(:age_during_tax_year) { 22 }
      let(:full_time_student) { "no" }

      it "they do not meet the conditions for checkbox 4a" do
        expect(efile_submission_dependent.schedule_eic_4a?).to eq false
      end
    end
  end

  describe "#schedule_eic_4b?" do
    let(:dependent) { create :dependent, permanently_totally_disabled: permanently_totally_disabled }
    let(:efile_submission_dependent) { create :efile_submission_dependent, dependent: dependent, age_during_tax_year: age_during_tax_year }

    context "when the dependent was disabled and under 19" do
      let(:age_during_tax_year) { 18 }
      let(:permanently_totally_disabled) { "yes" }

      it "they meet the conditions for checkbox 4b" do
        expect(efile_submission_dependent.schedule_eic_4b?).to eq true
      end
    end

    context "when the dependent was disabled but not under 19" do
      let(:age_during_tax_year) { 21 }
      let(:permanently_totally_disabled) { "yes" }

      it "they do not meet the conditions for checkbox 4b" do
        expect(efile_submission_dependent.schedule_eic_4b?).to eq false
      end
    end

    context "when the dependent was under 19 but not disabled" do
      let(:age_during_tax_year) { 18 }
      let(:permanently_totally_disabled) { "no" }

      it "they do not meet the conditions for checkbox 4b" do
        expect(efile_submission_dependent.schedule_eic_4b?).to eq false
      end
    end
  end
end
