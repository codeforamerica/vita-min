module DateAccessible
  extend ActiveSupport::Concern

  TAX_YEAR = Date.new(Rails.configuration.statefile_current_tax_year)

  included do
    private

    # Calls `date_reader` and `date_writer` on specified date properties to set
    # getters and setters on the specified date properties. For use with
    # `cfa_date_select`
    #
    # @see cfa_date_select
    #
    # @param properties [Array<Symbol> | Symbol] Either an individual date property or an array to set many at once
    def self.date_accessor(*properties)
      self.date_reader(*properties)
      self.date_writer(*properties)

      properties.each do |property|
        attr_accessor "#{property}_month_val", "#{property}_day_val", "#{property}_year_val"
      end
    end

    # Creates *_day, *_month, and *_year setters for the specified date
    # properties. For use with `cfa_date_select`
    #
    # @see cfa_date_select
    #
    # @param properties [Array<Symbol> | Symbol] Either an individual date property or an array to set many at once
    def self.date_reader(*properties)
      properties = [properties] unless properties.is_a?(Enumerable)

      properties.each do |property|
        self.define_method("#{property}_month") do
          instance_variable_get("@#{property}_month_val") || send(property)&.month
        end

        self.define_method("#{property}_year") do
          instance_variable_get("@#{property}_year_val") || send(property)&.year
        end

        self.define_method("#{property}_day") do
          instance_variable_get("@#{property}_day_val") || send(property)&.day
        end
      end
    end

    # Creates *_day=, *_month=, and *_year= setter methods for the specified date
    # properties. For use with `cfa_date_select`
    #
    # @see cfa_date_select
    #
    # @param properties [Array<Symbol> | Symbol] Either an individual date property or an array to set many at once
    def self.date_writer(*properties)
      properties = [properties] unless properties.is_a?(Enumerable)

      properties.each do |property|
        self.define_method("#{property}_month=") do |month|
          instance_variable_set("@#{property}_month_val", month.presence&.to_i)
          try_set_date(property)
        end

        self.define_method("#{property}_year=") do |year|
          instance_variable_set("@#{property}_year_val", year.presence&.to_i)
          try_set_date(property)
        end

        self.define_method("#{property}_day=") do |day|
          instance_variable_set("@#{property}_day_val", day.presence&.to_i)
          try_set_date(property)
        end
      end
    end

    # date part. Values can be strings as long as #to_i renders an appropriate
    # integer. Note that Date#change only accepts :year, :month, and :day as
    # keys, all other keys will be treated as nothing was passed at all.
    #
    # Note that until all three fragments are passed; month, day, and year, the
    # year is nonsense. This is expected to be caught by validation.
    #
    # @see Date#change
    #
    # @param date_property [Symbol] The property to manipulate
    # @param args [Hash<Symbol, String | Integer>] Arguments conforming to Date#change
    def try_set_date(property)
      year = instance_variable_get("@#{property}_year_val")
      month = instance_variable_get("@#{property}_month_val")
      day = instance_variable_get("@#{property}_day_val")

      if year.present? && month.present? && day.present?
        begin
          self.send("#{property}=", Date.new(year, month, day))
        rescue Date::Error
          self.send("#{property}=", nil)
        end
      else
        self.send("#{property}=", nil)
      end
    end
  end
end
