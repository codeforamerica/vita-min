class SubmissionBundle
  include XmlMethods
  def initialize(submission)
    @submission = submission
  end

  def build
    dir = Dir.mktmpdir(nil, Rails.root.join("tmp"))
    begin
      archive_directory_path = "#{dir}/#{@submission.irs_submission_id}.zip"
      Dir.mkdir("#{dir}/manifest")
      Dir.mkdir("#{dir}/xml")
      Dir.mkdir("#{dir}/irs")
      Dir.mkdir("#{dir}/irs/xml")
      File.open("#{dir}/manifest/manifest.xml", "w+") do |f|
        f.write(manifest_content)
      end
      File.open("#{dir}/xml/submission.xml", "w+") do |f|
        f.write(submission_content)
      end
      File.open("#{dir}/irs/xml/federalreturn.xml", "w+") do |f|
        f.write(federal_return_content)
      end

      input_filenames = ['manifest/manifest.xml', 'xml/submission.xml', 'irs/xml/federalreturn.xml']
      Zip::File.open(archive_directory_path, create: true) do |zipfile|
        input_filenames.each do |filename|
          zipfile.add(filename, File.join(dir, filename))
        end
      end
      if @submission.submission_bundle
        @submission.submission_bundle.attach(
          io: File.open(archive_directory_path),
          filename: "#{@submission.irs_submission_id}.zip",
          content_type: 'application/zip'
        )
      end
      SubmissionBundleResponse.new
    rescue SubmissionBundleError
      SubmissionBundleResponse.new(errors: @errors)
    ensure
      FileUtils.remove_entry_secure dir
    end
  end

  private

  def manifest_content
    response = @submission.manifest_class.build(@submission)
    if response.valid?
      response.document
    else
      @errors = response.errors
      raise SubmissionBundleError
    end
  end

  def submission_content
    response = @submission.bundle_class.build(@submission)
    if response.valid?
      delete_blank_nodes(response.document)
      response.document
    else
      @errors = response.errors
      raise SubmissionBundleError
    end
  end

  def federal_return_content
    @submission.data_source.raw_direct_file_data
  end

  def self.build(*args)
    new(*args).build
  end
end

class SubmissionBundleError < StandardError; end

class SubmissionBundleResponse
  attr_accessor :errors
  def initialize(errors: [])
    @errors = errors
  end

  def valid?
    @errors.empty?
  end
end
