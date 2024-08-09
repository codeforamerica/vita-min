class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Allow counting up to a max number; see https://alexcastano.com/the-hidden-cost-of-the-invisible-queries-in-rails/#how-far-do-you-plan-to-count
  scope :count_greater_than?, ->(n) { limit(n + 1).count > n }

  def self.enum(**enums)
    super

    enums.each do |enum_name, _|
      mapping = defined_enums[enum_name.to_s]
      next if mapping.nil?
      attribute(enum_name) do |subtype|
        subtype = subtype.subtype if ActiveRecord::Enum::EnumType === subtype # rubocop:disable Style/CaseEquality
        EnumTypeWithoutValidValueAssertion.new(enum_name, mapping, subtype)
      end

      validates_inclusion_of enum_name, { in: mapping.keys + mapping.values, allow_blank: true }
    end
  end

  def self.date_accessor(properties)
    properties = [properties] unless properties.is_a?(Enumerable)

    properties.each do |property|
      self.date_reader(property)
      self.date_writer(property)
    end
  end

  def self.date_reader(properties)
    properties = [properties] unless properties.is_a?(Enumerable)

    properties.each do |property|
      self.define_method("#{property}_month") do
        send(property)&.month
      end

      self.define_method("#{property}_year") do
        send(property)&.year
      end

      self.define_method("#{property}_day") do
        send(property)&.day
      end
    end
  end

  def self.date_writer(properties)
    properties = [properties] unless properties.is_a?(Enumerable)

    properties.each do |property|
      self.define_method("#{property}_month=") do |month|
        change_date_property(property, month: month) unless month.empty?
      end

      self.define_method("#{property}_year=") do |year|
        change_date_property(property, year: year) unless year.empty?
      end

      self.define_method("#{property}_day=") do |day|
        change_date_property(property, day: day) unless day.empty?
      end

      # Takes in valid arguments to Date#change. Will create a new date if
      # `date_of_contribution` is nil, otherwise will merely modify the correct
      # date part. Values can be strings as long as #to_i renders an appropriate
      # integer
      #
      # @see {Date#change}
      #
      # @param args [Hash<Symbol, String | Integer>] Arguments conforming to Date#change
      # @return [String | Integer] Whatever the date_part passed in was. Incidental
      self.define_method(:change_date_property) do |date_property, args|
        existing_date = send(date_property) || Date.new

        self.send(
          "#{date_property}=",
          existing_date.change(**args.transform_values(&:to_i))
        )
      end
    end
  end
end
