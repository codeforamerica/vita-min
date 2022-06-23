Rails.application.reloader.to_prepare do
  IrsLanguagesHelper.import(Rails.root.join("app/helpers/irs_languages.yml"))
end