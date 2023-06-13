# frozen_string_literal: true

class DetectBlurInDocumentJob < ApplicationJob
  def perform(document:)
    # Download the file
    downloaded_document = Tempfile.create('blurcheck-result')
    downloaded_document.write(document.upload.download)
    downloaded_document.close

    shell_output_file = Tempfile.create("blurcheck-output")
    argv = ["node", full_path_to_script, downloaded_document.path]
    pid = Process.spawn(*argv, chdir: javascript_working_directory, in: "/dev/null", out: shell_output_file.path, err: :out)
    Process.wait(pid)

    raise Error.new("Process failed to exit?") unless $?.exited?
    downloaded_document.close!

    output_body = JSON.parse(File.readlines(shell_output_file.path).join)
    shell_output_file.close!
    blurriness_score = output_body[:blur_score]

    # Update the record
    # NOTE: Do we need to notify anything/aynone?
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
