# frozen_string_literal: true

class DetectBlurInDocumentJob < ApplicationJob
  def perform(document:)
    downloaded_document = Tempfile.create('blurcheck')
    File.write(document.upload.download)

    temp_file = Tempfile.new
    argv = ["node", full_path_to_script, downloaded_document.path]
    pid = Process.spawn(*argv, chdir: javascript_working_directory, in: "/dev/null", out: temp_file.path, err: :out)
    Process.wait(pid)

    raise Error.new("Process failed to exit?") unless $?.exited?
    output_body = JSON.parse(File.readlines(temp_file.path).join)
    blurriness_score = output_body[:blur_score]

    document.update(computed_blurriness: blurriness_score)
  end

  private

  def full_path_to_script
    File.expand_path(File.expand_path(File.dirname(__FILE__)) + "/vendor/opencv-blur/index.js")
  end

  def javascript_working_directory
    File.dirname(full_path_to_script, 2)
  end
end
