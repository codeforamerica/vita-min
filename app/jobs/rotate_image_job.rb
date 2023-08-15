class RotateImageJob < ApplicationJob
  def perform(document, rotation)

    document.upload.open do |tempfile|
      processed = ImageProcessing::MiniMagick
        .source(tempfile.path)
        .rotate(rotation)
        .call
      document.upload.attach(
        io: File.open(processed.path),
        filename: File.basename(document.upload.filename.to_s)
      )
    end
  end

  def priority
    PRIORITY_MEDIUM
  end
end