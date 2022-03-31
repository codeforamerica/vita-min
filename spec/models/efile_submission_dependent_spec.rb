# == Schema Information
#
# Table name: efile_submission_dependents
#
#  id                  :bigint           not null, primary key
#  age_during_tax_year :integer
#  qualifying_child    :boolean
#  qualifying_ctc      :boolean
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

  describe '.create_from_eligibility' do
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
          EfileSubmissionDependent.create_from_eligibility(submission, dependent)
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
        allow(eligibility_double).to receive(:qualifying_relative?).and_return false
        allow(eligibility_double).to receive(:age).and_return 5
      end

      it "calculates eligibility" do
        EfileSubmissionDependent.create_from_eligibility(submission, dependent)
        expect(eligibility_double).to have_received(:qualifying_ctc?).exactly(2).times
        expect(eligibility_double).to have_received(:qualifying_child?).exactly(2).times
        expect(eligibility_double).to have_received(:qualifying_relative?).exactly(2).times
      end

      context "when the tested dependent is eligible for something" do
        it "creates an EfileSubmissionDependent object" do
          expect {
            EfileSubmissionDependent.create_from_eligibility(submission, dependent)
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
            EfileSubmissionDependent.create_from_eligibility(submission, dependent)
          }.not_to change(EfileSubmissionDependent, :count)
        end
      end
    end
  end
end
