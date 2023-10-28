module Efile
  class TaxFormLine
    attr_reader :line_id, :source_description, :inputs
    attr_accessor :value_access_tracker

    def initialize(line_id, value, source_description, inputs)
      @line_id = line_id
      @value = value
      @source_description = source_description
      @inputs = inputs
    end

    def pdf_label
      self.class.line_data[@line_id.to_s]&.fetch('label')
    end

    def value
      @value_access_tracker&.track(line_id)
      @value
    end

    def self.from_data_source(line_id, data_source, field)
      new(line_id, data_source.send(field), "#{data_source.class}##{field}", [])
    end

    def self.line_data
      @line_data ||= YAML.load_file(Rails.root.join('app', 'lib', 'efile', 'line_data.yml'))
    end
  end
end
