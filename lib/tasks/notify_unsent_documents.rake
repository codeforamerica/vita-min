namespace :documents do
  desc 'sends Zendesk comments for all Intakes with unsent documents'
  task notify_unsent: [:environment] do
    service = UnsentDocumentsService.new
    service.detect_unsent_docs_and_notify
  end
end
