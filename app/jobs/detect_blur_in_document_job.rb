# frozen_string_literal: true

class DetectBlurInDocumentJob < ApplicationJob
  def perform(document:)
    # TODO: Obtain the path to the root JavaScript directory that'll handle this job.
    # TODO: Open up the process and wait for it to complete.

    downloaded_document = Tempfile.create('blurcheck')
    File.write(document.upload.download)

    temp_file = Tempfile.new
    argv = ["node", full_path_to_script, downloaded_document.path]
    pid = Process.spawn(*argv, chdir: javascript_working_directory, in: temp_file.path)
    Process.wait(pid)
    raise Error.new("Process failed to exit?") unless $?.exited?
    output = temp_file.path
  end

  private

  def full_path_to_script
    "blur_check.js"
  end

  def javascript_working_directory
    File.dirname(FILE)
  end
end
