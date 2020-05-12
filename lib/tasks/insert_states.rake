##
#these tasks manage state information
namespace :db do
  desc 'loads states'
  task insert_states: [:environment] do
    include StateImporter
    insert_states
  end
end

