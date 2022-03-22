Rails.application.reloader.to_prepare do
  Efile::Timezone.import(Rails.root.join("lib/timezone_overrides.yml"))
end
