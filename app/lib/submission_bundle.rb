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
        f.write(manifest)
      end
      File.open("#{dir}/xml/submission.xml", "w+") do |f|
        f.write(return_1040)
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
        content_type: 'application/zip'
      )
      SubmissionBundleResponse.new
    rescue SubmissionBundleError
      SubmissionBundleResponse.new(errors: @errors)
    ensure
      FileUtils.remove_entry_secure dir
    end
  end

  private

  def manifest
    response = SubmissionBuilder::Manifest.build(@submission)
    if response.valid?
      response.document
    else
      @errors = response.errors
      raise SubmissionBundleError
    end
  end

  def return_1040
    response = submission_class.build(@submission, documents: @documents)
    if response.valid?
      response.document
    else
      @errors = response.errors
      raise SubmissionBundleError
    end
  end

  def submission_class
    year = @submission.tax_return.year
    "SubmissionBuilder::TY#{year}::Return1040".constantize
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