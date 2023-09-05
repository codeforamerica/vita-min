Rails.application.reloader.to_prepare do
  Efile::Ny::Constants.import(Rails.root.join("app/lib/efile/ny/counties.json"))
end
