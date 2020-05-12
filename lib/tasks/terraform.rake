namespace :db do
  desc 'tear down and rebuild the database'
  task terraform: [:drop, :create, :migrate, :upsert_vita_partners] do
    puts "database rebuilt!"
  end
end
