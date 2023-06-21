class DetectBlurInDocumentJob < ApplicationJob
  def perform(document:)
    return if document.is_pdf?
    # Download the file
    image_bytes = document.upload.download

    downloaded_document = Tempfile.create('blurcheck-result', binmode: true)
    downloaded_document.write(image_bytes)
    downloaded_document.close

    # cv = PyCall.import_module("cv2")
    # image = cv.imread(downloaded_document.path)
    # grayscale_image = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
    # fm = cv.Laplacian(grayscale_image, cv.CV_64F).var()

    # TODO: Call JS method to run CV and get back score
    process = IO.popen(["node", path_to_javascript_file, downloaded_document.path])
    Process.wait(process.pid)
    output = process.readlines
    puts output
  end

  private

  def path_to_javascript_file
    File.expand_path("../javascript/scripts/opencv-blur.js", File.dirname(__FILE__))
  end
end
