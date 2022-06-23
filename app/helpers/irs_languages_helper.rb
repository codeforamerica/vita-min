module IrsLanguagesHelper
  def self.import(file)
    @@irs_languages = YAML.load_file(file)['irs_languages'].map do |lang|
      [lang["name"], lang["key"]]
    end.to_h
  end

  def irs_languages
    IrsLanguagesHelper.class_variable_get(:@@irs_languages)
  end

  def default_irs_language(irs_language_preference)
    return {} if irs_language_preference.present?

    return { selected: "spanish" } if I18n.locale == :es

    { selected: "english" }
  end
end
