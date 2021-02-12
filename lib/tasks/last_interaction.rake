namespace :last_interaction do
  desc "seeds more appropriate last_interaction value onto all existing clients."
  task "backfill" => :environment do
    # break job into separate processable jobs in batches of 1000.
    (0..Client.all.size).step(1000) do |i|

      next if i > Client.last.id

      start = i
      finish = start + 999
      BackfillAppropriateLastInteractionValue.perform_later(start: start, finish: finish)
    end
  end
end