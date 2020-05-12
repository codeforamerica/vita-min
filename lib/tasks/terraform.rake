namespace :db do
  desc 'tear down and rebuild the database'
  task terraform: [:drop, :create, :migrate] do
    puts "database rebuilt!"
  end
end