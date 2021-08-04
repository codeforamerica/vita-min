require "rails_helper"

describe Efile::SubmissionRejectionParser do
  let(:raw_response) { file_fixture("irs_acknowledgement_rejection.xml").read }
  let(:transition) { create :efile_submission_transition, :rejected, metadata: { raw_response: raw_response } }
  before do
    # skip before action on model persistance
    allow_any_instance_of(EfileSubmissionTransition).to receive(:persist_efile_error_from_metadata).and_return false
  end

  describe '#to_xml' do
    it 'outputs the raw response to a Nokogiri XML document' do
      obj = Efile::SubmissionRejectionParser.new(transition)
      expect(obj.to_xml).to be_an_instance_of Nokogiri::XML::Document
    end
  end

  describe "#persist_errors" do
    context "when the rejection errors do not exist in the db yet" do
      it "associates the efile errors with transition and creates the EfileError object for new errors" do
        expect {
          Efile::SubmissionRejectionParser.new(transition).persist_errors
        }.to change(transition.efile_errors, :count).by(2)
         .and change(EfileError, :count).by(2)
      end
    end

    context "when the rejection errors already exist in the db" do
      let!(:other_transition) { create :efile_submission_transition, :rejected, metadata: { raw_response: raw_response } }

      before do
        Efile::SubmissionRejectionParser.new(other_transition).persist_errors
      end

      it "associates the efile errors with transition, but uses the existing EfileError objects" do
        expect {
          Efile::SubmissionRejectionParser.new(transition).persist_errors
        }.to change(transition.efile_errors, :count).by(2)
         .and change(EfileError, :count).by(0)
        expect(EfileError.count).to eq 2
      end
    end
  end
end