require "rails_helper"

RSpec.describe StateFile::Questions::BaseReviewController do
  before do
    sign_in intake
  end

  describe '#income_documents_present?' do
    context 'when no income documents are present' do
      let(:intake) { create :state_file_id_intake, raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("az_married_filing_joint")}

      it 'returns false' do
        expect(controller.send(:income_documents_present?)).to be_falsy
      end
    end

    context 'when income documents are present' do
      let(:intake) { create :state_file_id_intake }

      it 'returns true' do
        expect(controller.send(:income_documents_present?)).to be_truthy
      end
    end
  end
end

