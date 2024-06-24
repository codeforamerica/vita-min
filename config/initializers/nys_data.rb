Rails.application.reloader.to_prepare do
  StateFile::Ny::Efile::Constants.import(Rails.root.join("app/lib/efile/ny/counties.json"))
end
