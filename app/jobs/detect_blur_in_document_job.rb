class DetectBlurInDocumentJob < ApplicationJob
  def perform(document:)
    return if document.is_pdf?
    # Download the file
    image_bytes = document.upload.download

    downloaded_document = Tempfile.create('blurcheck-result', binmode: true)
    downloaded_document.write(image_bytes)
    downloaded_document.close

    cv = PyCall.import_module("cv2")
    image = cv.imread(downloaded_document.path)
    return unless image.present?

    grayscale_image = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
    fm = cv.Laplacian(grayscale_image, cv.CV_64F).var()
    document.update!(blur_score: fm)
  end
end
