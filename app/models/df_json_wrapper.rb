class DfJsonWrapper

  def initialize(json)
    @json = json
  end

  def self.json_reader(mappings)
    mappings.each do |selector_name, selector_info|
      selector_info => {type:, key:}
      case type
      when :money_amount
        define_method(selector_name) do
          df_json_value(key)&.to_d || 0
        end
      when :date
        define_method(selector_name) do
          Date.parse(df_json_value(key))
        end
      when :string, :boolean
        define_method(selector_name) do
          df_json_value(key)
        end
      else
        define_method(selector_name) do
          df_json_value(key)
        end
      end
    end
  end

  def df_json_value(key)
    key_path = key.split
    @json.dig(*key_path)
  end
end
