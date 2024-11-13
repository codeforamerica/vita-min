class DfJsonWrapper

  def initialize(json)
    @json = json
  end

  def self.json_accessor(mappings)
    json_reader(mappings)
    json_writer(mappings)
  end

  def self.json_reader(mappings)
    mappings.each do |selector_name, selector_info|
      selector_info => { type:, key: }
      key_path = key.split
      case type
      when :money_amount
        define_method(selector_name) do
          df_json_value(key_path)&.to_d || 0
        end
      when :date
        define_method(selector_name) do
          Date.parse(df_json_value(key_path)) if df_json_value(key_path).present?
        end
      when :string, :boolean
        define_method(selector_name) do
          df_json_value(key_path)
        end
      else
        define_method(selector_name) do
          df_json_value(key_path)
        end
      end
    end
  end

  def self.json_writer(mappings)
    mappings.each do |selector_name, selector_info|
      selector_info => { type:, key: }
      key_path = key.split
      case type
      when :date
        define_method("#{selector_name}=") do |value|
          df_json_set(key_path, value.to_s)
        end
      else
        define_method("#{selector_name}=") do |value|
          df_json_set(key_path, value)
        end
      end
    end
  end

  def df_json_set(key_path, value, json = @json)
    if key_path.count == 1
      json[key_path[0]] = value
    else
      df_json_set(key_path[1..], value, json[key_path[0]])
    end
  end

  def df_json_value(key_path)
    @json.dig(*key_path)
  end
end
