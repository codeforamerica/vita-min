require "rails_helper"

describe Efile::SubmissionErrorParser do
  let(:raw_response) { file_fixture("irs_acknowledgement_rejection.xml").read }
  let(:transition) { create :efile_submission_transition, :rejected, metadata: { raw_response: raw_response } }

  describe '#persist_errors' do
    context "when only an error code is provided" do
      context "when a matching error does not already exist" do
        let(:transition) { create :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040" } }

        it "creates a new EfileError object" do
          Efile::SubmissionErrorParser.new(transition).persist_errors
          expect(EfileError.count).to eq 1
          expect(transition.efile_errors.count).to eq 1
        end
      end

      context "when a matching error already exists" do
        before do
          EfileError.create(code: "IRS-1040-PROBS", message: "You have a problem.", source: "irs")
        end

        let(:transition) { create :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040-PROBS" } }

        it "does not create a new EfileError object, but associates the existing one with the transition" do
          Efile::SubmissionErrorParser.new(transition).persist_errors
          expect(EfileError.count).to eq 1
          expect(transition.efile_errors.count).to eq 1
        end
      end
    end

    context "when a code and message and a source are provided" do
      context "when it matches an existing code/message/source" do
        let(:transition) { create :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040-PROBS", error_message: "You have a problem.", error_source: "irs" } }
        before do
          EfileError.create(code: "IRS-1040-PROBS", message: "You have a problem.", source: "irs")
        end

        it "does not create a new EfileError object" do
          Efile::SubmissionErrorParser.new(transition).persist_errors
          expect(EfileError.count).to eq 1
          expect(transition.efile_errors.count).to eq 1
        end
      end

      context "when it does not match an existing code/message/source pair" do
        let(:transition) { create :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040-PROBS", error_message: "You have a problem", error_source: "internal" } }

        before do
          EfileError.create(code: "IRS-1040-PROBS", message: "You have a problem.", source: "irs")
        end

        it "creates a new EfileError object" do
          expect {
            Efile::SubmissionErrorParser.new(transition).persist_errors
          }.to change(EfileError, :count).by(1)
          expect(transition.efile_errors.count).to eq 1
          expect(transition.efile_errors.first.message).to eq "You have a problem"
          expect(transition.efile_errors.first.source).to eq "internal"
        end
      end
    end

    context "when there is raw_response metadata" do
      let(:reject_transition) { create :efile_submission_transition, :rejected, metadata: { raw_response: raw_response } }

      it "creates a new EfileError object" do
        expect {
          Efile::SubmissionErrorParser.new(transition).persist_errors
        }.to change(transition.efile_errors, :count).by(2)
                                                    .and change(EfileError, :count).by(2)
      end
    end

    context "persisting errors from XML raw response metadata" do
      context "when the rejection errors do not exist in the db yet" do
        it "associates the efile errors with transition and creates the EfileError object for new errors" do
          expect {
            Efile::SubmissionErrorParser.new(transition).persist_errors
          }.to change(transition.efile_errors, :count).by(2)
                   .and change(EfileError, :count).by(2)
        end
      end

      context "when the rejection errors already exist in the db" do
        let!(:other_transition) { create :efile_submission_transition, :rejected, metadata: { raw_response: raw_response } }

        before do
          Efile::SubmissionErrorParser.new(other_transition).persist_errors
        end

        it "associates the efile errors with transition, but uses the existing EfileError objects" do
          expect {
            Efile::SubmissionErrorParser.new(transition).persist_errors
          }.to change(transition.efile_errors, :count).by(2)
                   .and change(EfileError, :count).by(0)
          expect(EfileError.count).to eq 2
        end

        context "with dependent association" do
          before do
            d = transition.efile_submission.intake.dependents.last
            d.update(ssn: "142111111")
            EfileSubmissionDependent.create(efile_submission: transition.efile_submission, dependent: d)
          end

          it "associates the efile error with the dependent specified in the FieldValueTxt if there is a match" do
            Efile::SubmissionErrorParser.new(transition).persist_errors
            expect(transition.efile_submission_transition_errors.last.dependent).to eq transition.efile_submission.qualifying_dependents.last.dependent
          end
        end
      end
    end

    context "persisting errors from bundle failure arrays" do
      let(:transition) { create :efile_submission_transition, :failed, metadata: { raw_response: raw_response } }
      context "when the raw response includes bank account issues" do
        let(:raw_response) { ["36:0: ERROR: Element '{http://www.irs.gov/efile}RoutingTransitNum': [facet 'pattern'] The value '' is not accepted by the pattern '(01|02|03|04|05|06|07|08|09|10|11|12|21|22|23|24|25|26|27|28|29|30|31|32)[0-9]{7}'.", "37:0: ERROR: Element '{http://www.irs.gov/efile}DepositorAccountNum': [facet 'pattern'] The value '' is not accepted by the pattern '[A-Za-z0-9\\-]+'.", "41:0: ERROR: Element '{http://www.irs.gov/efile}RoutingTransitNum': [facet 'pattern'] The value '' is not accepted by the pattern '(01|02|03|04|05|06|07|08|09|10|11|12|21|22|23|24|25|26|27|28|29|30|31|32)[0-9]{7}'.", "42:0: ERROR: Element '{http://www.irs.gov/efile}DepositorAccountNum': [facet 'pattern'] The value '' is not accepted by the pattern '[A-Za-z0-9\\-]+'.", "50:0: ERROR: Element '{http://www.irs.gov/efile}RoutingTransitNum': [facet 'pattern'] The value '' is not accepted by the pattern '(01|02|03|04|05|06|07|08|09|10|11|12|21|22|23|24|25|26|27|28|29|30|31|32)[0-9]{7}'.", "51:0: ERROR: Element '{http://www.irs.gov/efile}DepositorAccountNum': [facet 'pattern'] The value '' is not accepted by the pattern '[A-Za-z0-9\\-]+'.", "120:0: ERROR: Element '{http://www.irs.gov/efile}RoutingTransitNum': [facet 'pattern'] The value '' is not accepted by the pattern '(01|02|03|04|05|06|07|08|09|10|11|12|21|22|23|24|25|26|27|28|29|30|31|32)[0-9]{7}'.", "122:0: ERROR: Element '{http://www.irs.gov/efile}DepositorAccountNum': [facet 'pattern'] The value '' is not accepted by the pattern '[A-Za-z0-9\\-]+'."] }

        context "when the BANK DETAIL error already exists" do
          before do
            DefaultErrorMessages.generate!
          end

          it "creates an efile submission transition error with associated error" do
            Efile::SubmissionErrorParser.new(transition).persist_errors
            expect(transition.efile_submission_transition_errors.last.efile_error.code).to eq "BANK-DETAILS"
          end
        end
      end

      context "when the raw response includes anything else" do
        let(:raw_response) { ["a", 1234, "b"] }
        it "does nothing but does not break" do
          Efile::SubmissionErrorParser.new(transition).persist_errors
          expect(transition.efile_submission_transition_errors.count).to eq 0
        end
      end
    end
  end
end