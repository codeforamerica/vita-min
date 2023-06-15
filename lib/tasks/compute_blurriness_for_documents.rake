# frozen_string_literal: true

namespace :compute_blurriness_for_documents do
  desc 'Run blur detection against the provided set of documents'
  task :batch_process, [:document_type, :limit] => [:environment] do |t, args|
    args.with_defaults(limit: 200)
    document_type = args[:document_type]
    limit = args[:limit].to_i
    puts "Filtering for #{document_type} for at most #{limit} documents"

    Document.where(blurriness_score: nil, document_type: document_type).limit(limit).find_in_batches(batch_size: 10) do |document_set|
      Rails.logger.debug "Processing #{document_set.count} documents"
      for document in document_set
        DetectBlurInDocumentJob.perform_now(document: document)
      end
    end

    puts "Computation of blurriness for #{limit} documents has completed."
  end

  task :report, [:document_type] => [:environment] do |t, args|
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