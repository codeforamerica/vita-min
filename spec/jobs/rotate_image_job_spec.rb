require 'rails_helper'
require 'mini_magick'

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

    def image_dimensions(document)
      document.upload.open do |tempfile|
        image = MiniMagick::Image.open(tempfile.path)
        { width: image.width, height: image.height }
      end
    end

    it "rotates an image by an increment of 90 degrees" do
      original_dimensions = image_dimensions(document)

      described_class.new.perform(document, 90)

      new_dimensions = image_dimensions(document)
      expect(new_dimensions[:height]).to eq(original_dimensions[:width])
      expect(new_dimensions[:width]).to eq(original_dimensions[:height])
    end
  end
end