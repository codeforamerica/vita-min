namespace :ctc_vita_partners do
  desc 'add new CTC Valet Vita Partners'
  task add: [:environment] do
    UpdateCtcValetPartnersJob.perform
  end
end