namespace :search do
  desc 'Refresh tsvector columns for any searchable models'
  task refresh: [:environment] do
    SearchIndexer.refresh_search_index
  end
end
