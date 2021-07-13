class SubmissionBundle
  def initialize(submission, documents: [])
    @submission = submission
    @documents = documents
  end

  def build
    dir = Dir.mktmpdir(nil, Rails.root.join("tmp"))
    begin
      archive_directory_path = "#{dir}/#{@submission.irs_submission_id}.zip"
      Dir.mkdir("#{dir}/manifest")
      Dir.mkdir("#{dir}/xml")
      File.open("#{dir}/manifest/manifest.xml", "w+") do |f|
        f.write(SubmissionBuilder::Manifest.build(@submission).document)
      end
      File.open("#{dir}/xml/submission.xml", "w+") do |f|
        f.write(SubmissionBuilder::Return1040.build(@submission, documents: @documents).document)
      end
      input_filenames = ['manifest/manifest.xml', 'xml/submission.xml']

      Zip::File.open(archive_directory_path, create: true) do |zipfile|
        input_filenames.each do |filename|
          zipfile.add(filename, File.join(dir, filename))
        end
      end
      @submission.submission_bundle.attach(
          io: File.open(archive_directory_path),
          filename: "#{@submission.irs_submission_id}.zip",
          content_type: 'application/zip')
    ensure
      FileUtils.remove_entry_secure dir
    end
  end
end
