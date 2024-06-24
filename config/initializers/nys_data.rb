Rails.application.reloader.to_prepare do
  StateFile::Ny::Efile::Constants.import(Rails.root.join("app/lib/state_file/ny/efile/counties.json"))
end
