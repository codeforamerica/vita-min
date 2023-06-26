namespace :blur_score do
  desc 'Run blur detection against the provided set of documents'
  task :compute, [:document_type, :limit] => [:environment] do |t, args|
    args.with_defaults(limit: 200)
    document_type = args[:document_type]
    limit = args[:limit].to_i
    puts "Filtering for #{document_type} for at most #{limit} documents"

    Document.where(blur_score: nil, document_type: document_type).not.where(client_id: nil).limit(limit).find_in_batches(batch_size: 10) do |document_set|
      Rails.logger.debug "Processing #{document_set.count} documents"
      for document in document_set
        DetectBlurInDocumentJob.perform_later(document: document)
      end
    end

    puts "Computation of blur score for #{limit} documents has completed."
  end

  desc 'Generate a report with blur scores and doc urls'
  task :report, [:document_type] => [:environment] do |t, args|
    document_type = args[:document_type]
    documents = Document.where(document_type: document_type).where.not(blur_score: nil).order(blur_score: :asc)

    puts "Found #{documents.length} document(s) that have blur scores."

    puts "----------------------------------------------------"
    documents.each do |doc|
      puts "Document id: #{doc.id}"
      puts "Blur score: #{doc.blur_score}"
      puts doc.upload.url(expires_in: 10.minutes)
      puts "----------------------------------------------------"
    end
  end
end