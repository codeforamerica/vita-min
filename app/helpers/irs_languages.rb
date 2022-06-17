module IrsLanguages
  def self.hash
    @hash ||= IceNine.deep_freeze!(self.languages.to_h.invert)
  end

  def self.keys
    hash.keys
  end

  def self.display_values(locale)
    languages = hash.values
    return languages unless locale == :es

    languages.delete(IrsLanguages.name_for_key("spanish"))
    languages.unshift("Español")
  end

  def self.name_for_key(key)
    self.hash[key]
  end

  def self.key_for_name(name)
    return "spanish" if name == "Español"

    self.hash.key(name)
  end

  private

  def self.languages
    @languages ||= IceNine.deep_freeze!(
      (YAML.load_file(Rails.root.join("db/irs_languages.yml"))['irs_languages']).map do |lang|
        [lang["name"], lang["key"]]
      end
    )
  end
end
