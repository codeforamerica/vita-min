# frozen_string_literal: true

namespace :compute_blurriness_for_documents do
  desc 'Run blur detection against the provided set of documents'
  task :batch_process, [:document_type] => [:environment] do |t, args|
    document_type = args[:document_type]
    puts "Filtering for #{document_type}"

    Document.where(blurriness_score: nil, document_type: document_type).limit(200).find_in_batches(batch_size: 10) do |document_set|
      Rails.logger.debug "Processing #{document_set.count} documents"
      # TODO: Select all documents for a particular type who don't have blurriness info stored
      for document in document_set
        DetectBlurInDocumentJob.perform_now(document: document)
      end
    end
  end

  task :report_urls, [:document_type] => [:environment] do |t, args|
    document_type = args[:document_type]
    documents = Document.where(document_type: document_type).where.not(blurriness_score: nil).order(blurriness_score: :asc)

    puts "Found #{documents.length} document(s) that have blurriness scores."

    puts "----------------------------------------------------"
    documents.each do |doc|
      puts "Document id: #{doc.id}"
      puts "Blurriness score: #{doc.blurriness_score}"
      puts doc.upload.url.expires_in(10.minutes)
      puts "----------------------------------------------------"
    end
  end
end