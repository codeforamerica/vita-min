##
#these tasks manage state information
namespace :db do
  desc 'loads states'
  task upsert_states: [:environment] do
    include StateImporter
    upsert_states
  end
end

