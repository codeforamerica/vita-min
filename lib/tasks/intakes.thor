class Intakes < Thor
  default_task :help
  def self.exit_on_failure? = true

  desc 'delete STATE_CODE:ID STATE_CODE2:ID...', 'Deletes a given set of intakes specified by state and id'
  def delete(*ids)
    unless ids.all? { |id| id.match?(/\A[a-zA-Z]{2}:\d+\z/) }
      say 'IDs appear to be formatted incorrectly. Please double check', :red
      say "Received: #{ids.to_a}"
      exit
    end

    ids = ids.map(&:downcase) # AZ:123 => az:123
      .group_by { |value| value.split(':')[0] } # az:123 => {az: ['az:123']}
      .transform_values do |values| # ['az:123']
        values.map { |value| value.split(':')[1].to_i} # ['az:123''] => [123]
      end

    say "Looking up intakes for the following states", :green
    say ids.keys

    intakes = {}
    ids.each do |state, state_ids|
      intakes[state] = find_intakes(state:, ids: state_ids)
    end

    say "Found the following number of intakes", :green
    say intakes.transform_values(&:count)

    answer = ask "Would you like to delete these intakes?", :magenta, limited_to: ['y', 'n'], default: 'n'

    unless answer == 'y'
      say 'Aborting...', :red
      exit
    end

    # {az: ActiveRecord::Relation, md: ActiveRecord::Relation}
    say "Deleting #{intakes.transform_values(&:count).values.sum} records and their related models...", :red

    intakes.each_value(&:destroy_all)

    say "Specified records deleted!", :green
  end

  no_tasks do
    def find_intakes(state:, ids:)
      intake_class = ::StateFile::StateInformationService.intake_class(state)
      say "Intake class '#{intake_class.name}' selected", :cyan if options[:debug]

      intake_class.where(id: ids)
    end
  end
end
