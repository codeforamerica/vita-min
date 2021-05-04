class BackfillMarkedAsFlagged < ApplicationJob
  def perform(start: 0, finish: nil)
    successes = []
    errors = []
    Client.find_each(start: start, finish: finish) do |client|
      if client.marked_as_flagged.present?
        puts "SKIPPING #{client.id}: marked_as_flagged is already set."
        next
      end

      response_needed = client.response_needed_since

      marked_as_flagged_value = response_needed.present?
      if client.update(marked_as_flagged: marked_as_flagged_value)
        successes << client.id
      else
        errors << client.id
      end
    end
    puts "Successfully updated the following clients: #{successes}"
    puts "Errors updating the following clients: #{errors}"
  end
end