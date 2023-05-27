class RotateImageJob < ApplicationJob
  queue_as :default

  def perform(image, rotation)
    if image
      processed = ImageProcessing::MiniMagick
                    .source(image)
                    .rotate(rotation_degrees)
                    .call
      processed
      @document.update(upload)
    end
    return
  end
end