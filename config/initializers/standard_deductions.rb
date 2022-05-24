Rails.application.reloader.to_prepare do
  StandardDeductions.import(Rails.root.join("app/lib/standard_deductions.yml"))
end
