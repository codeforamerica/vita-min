class RotateImageJob < ApplicationJob
  queue_as :default

  def perform(document, rotation)
    puts "++++++++++++++++ we made it here +++++++++++++++++++++++++++"
    image = document.upload.download

    processed = ImageProcessing::MiniMagick
                  .source(image.path)
                  .rotate(rotation)
                  .call
    # document.update(upload: processed)
  end
end