require "rails_helper"

describe Efile::SubmissionErrorParser do
  let(:raw_response) { file_fixture("irs_acknowledgement_rejection.xml").read }
  let(:transition) { create :efile_submission_transition, :rejected, metadata: { raw_response: raw_response } }

  describe '#to_xml' do
    it 'outputs the raw response to a Nokogiri XML document' do
      obj = Efile::SubmissionErrorParser.new(transition)
      expect(obj.to_xml).to be_an_instance_of Nokogiri::XML::Document
    end
  end

  describe '#persist_efile_errors_from_transition_metadata' do
    context "when only an error code is provided" do
      context "when a matching error does not already exist" do
        let(:transition) { create :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040" } }

        it "creates a new EfileError object" do
          Efile::SubmissionErrorParser.new(transition).persist_efile_errors_from_transition_metadata
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
          Efile::SubmissionErrorParser.new(transition).persist_efile_errors_from_transition_metadata
          expect(EfileError.count).to eq 1
          expect(transition.efile_errors.count).to eq 1
        end
      end
    end

    context "when a code and message and a source are provided" do
      context "when it matches an existing code/message/source" do
        before do
          EfileError.create(code: "IRS-1040-PROBS", message: "You have a problem.", source: "irs")
        end
        let(:transition) { create :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040-PROBS", error_message: "You have a problem.", error_source: "irs" } }

        it "does not create a new EfileError object" do
          Efile::SubmissionErrorParser.new(transition).persist_efile_errors_from_transition_metadata
          expect(EfileError.count).to eq 1
          expect(transition.efile_errors.count).to eq 1
        end
      end

      context "when it does not match an existing code/message/source pair" do
        before do
          EfileError.create(code: "IRS-1040-PROBS", message: "You have a problem.", source: "irs")
        end

        let(:transition) { create :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040-PROBS", error_message: "You have a problem", error_source: "internal" } }

        it "creates a new EfileError object" do
          expect {
            Efile::SubmissionErrorParser.new(transition).persist_efile_errors_from_transition_metadata
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
          Efile::SubmissionErrorParser.new(transition).persist_efile_errors_from_transition_metadata
        }.to change(transition.efile_errors, :count).by(2)
                                                    .and change(EfileError, :count).by(2)      end
    end
  end

  describe "#persist_errors_from_raw_response" do
    context "when the rejection errors do not exist in the db yet" do
      it "associates the efile errors with transition and creates the EfileError object for new errors" do
        expect {
          Efile::SubmissionErrorParser.new(transition).persist_errors_from_raw_response
        }.to change(transition.efile_errors, :count).by(2)
         .and change(EfileError, :count).by(2)
      end
    end

    context "when the rejection errors already exist in the db" do
      let!(:other_transition) { create :efile_submission_transition, :rejected, metadata: { raw_response: raw_response } }

      before do
        Efile::SubmissionErrorParser.new(other_transition).persist_errors_from_raw_response
      end

      it "associates the efile errors with transition, but uses the existing EfileError objects" do
        expect {
          Efile::SubmissionErrorParser.new(transition).persist_errors_from_raw_response
        }.to change(transition.efile_errors, :count).by(2)
         .and change(EfileError, :count).by(0)
        expect(EfileError.count).to eq 2
      end

      context "with dependent association" do
        before do
          d = transition.efile_submission.dependents.last
          d.update(ssn: "142111111")
        end

        it "associates the efile error with the dependent specified in the FieldValueTxt if there is a match" do
          Efile::SubmissionErrorParser.new(transition).persist_errors_from_raw_response
          expect(transition.efile_submission_transition_errors.last.dependent).to eq transition.efile_submission.dependents.last
        end
      end
    end
  end
end