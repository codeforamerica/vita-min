class DfJsonWrapper

  def initialize(json)
    @json = json
  end

  def self.define_json_readers
    self.selectors.each do |selector_name, selector_info|
      selector_type = selector_info[:type]
      case selector_type
      when :money_amount
        define_method(selector_name) do
          df_json_value(__method__)&.to_d || 0
        end
      when :date
        define_method(selector_name) do
          Date.parse(df_json_value(__method__))
        end
      when :string, :boolean
        define_method(selector_name) do
          df_json_value(__method__)
        end
      else
        define_method(selector_name) do
          df_json_value(__method__)
        end
      end
    end
  end

  def df_json_value(selector_name)
    key_path = selectors[selector_name][:key].split
    @json.dig(*key_path)
  end

  def self.selectors
    raise NotImplementedError, "Must define SELECTORS"
  end

  delegate :selectors, to: :class
end
