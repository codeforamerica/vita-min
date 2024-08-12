module DateAccessible
  extend ActiveSupport::Concern

  included do
    # Calls `date_reader` and `date_writer` on specified date properties to set
    # getters and setters on the specified date properties. For use with
    # `cfa_date_select`
    #
    # @see cfa_date_select
    #
    # @param properties [Array<Symbol> | Symbol] Either an individual date property or an array to set many at once
    def self.date_accessor(properties)
      self.date_reader(properties)
      self.date_writer(properties)
    end

    # Creates *_day, *_month, and *_year setters for the specified date
    # properties. For use with `cfa_date_select`
    #
    # @see cfa_date_select
    #
    # @param properties [Array<Symbol> | Symbol] Either an individual date property or an array to set many at once
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

    # Creates *_day=, *_month=, and *_year= setter methods for the specified date
    # properties. For use with `cfa_date_select`
    #
    # @see cfa_date_select
    #
    # @param properties [Array<Symbol> | Symbol] Either an individual date property or an array to set many at once
    def self.date_writer(properties)
      properties = [properties] unless properties.is_a?(Enumerable)

      properties.each do |property|
        self.define_method("#{property}_month=") do |month|
          change_date_property(property, month: month) unless month.blank?
        end

        self.define_method("#{property}_year=") do |year|
          change_date_property(property, year: year) unless year.blank?
        end

        self.define_method("#{property}_day=") do |day|
          change_date_property(property, day: day) unless day.blank?
        end
      end
    end

    # Takes in valid arguments to Date#change. Will create a new date if
    # `date_of_contribution` is nil, otherwise will merely modify the correct
    # date part. Values can be strings as long as #to_i renders an appropriate
    # integer
    #
    # @see Date#change
    #
    # @param date_property [Symbol] The property to manipulate
    # @param args [Hash<Symbol, String | Integer>] Arguments conforming to Date#change
    def change_date_property(date_property, args)
      existing_date = send(date_property) || Date.new

      self.send(
        "#{date_property}=",
        existing_date.change(**args.transform_values(&:to_i))
      )
    end
  end
end
