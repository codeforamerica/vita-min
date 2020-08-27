##
#these tasks manage state information
namespace :db do
  desc 'loads states'
  task insert_states: [:environment] do
    StateImporter.insert_states
  end
end

