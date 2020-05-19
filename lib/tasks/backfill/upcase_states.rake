##
# this backfill upcases all state and state_of_residence values for intakes
#
# this backfill was created 2020-05-19, and should be run after the creation
# of the State and SourceParameters model and merge of associated code.
#
namespace :backfill do
  desc 'this backfill upcases all state and state_of_residence values for intakes'
  task upcase_states: [:environment] do
    Intake.all.each { |intake| intake.update(state: intake.state.upcase, state_of_residence: intake.state_of_residence.upcase) }
  end
end
