unless Rails.env.production?
  Seeder.new.run
end

