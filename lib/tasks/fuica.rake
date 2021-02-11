namespace :fuica do
  desc "seeds appropriate fuica value onto all existing clients."
  task "seed" => :environment do
    client_groups = Client.all.size / 1000
    puts("client count", Client.all.size)
    # break job into separate processable jobs in batches of 1000.
    (0..Client.all.size).step(1000) do |i|

      next if i > Client.last.id

      start = i * 1000
      finish = start + 999
      GenerateUnansweredIncomingInteractionDataJob.perform_later(start: start, finish: finish)
    end
  end
end