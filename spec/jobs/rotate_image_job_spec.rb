require 'rspec'

# describe 'RotateImageJob' do
#   before do
#     # Do nothing
#   end
#
#   after do
#     # Do nothing
#   end
#
#   context 'when condition' do
#     it 'succeeds' do
#       pending 'Not implemented'
#     end
#   end
# end

describe RotateImageJob, type: :job do
  describe "#perform" do
    let(:document) { create(:document) }

    before do
      allow(Document).to receive(:find).and_return(document)
      allow(document).to receive(:convert_heic_upload_to_jpg!)
    end

    it "converts a document with a heic image to jpg" do
      HeicToJpgJob.new.perform(document.id)

      expect(Document).to have_received(:find).with(document.id)
      expect(document).to have_received(:convert_heic_upload_to_jpg!)
    end
  end
end