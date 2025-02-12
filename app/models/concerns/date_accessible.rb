module DateAccessible
  extend ActiveSupport::Concern

  TAX_YEAR = Date.new(Rails.configuration.statefile_current_tax_year)

  included do

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
        attr_reader :"#{property}_month", :"#{property}_year", :"#{property}_day"
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
        attr_writer :"#{property}_month", :"#{property}_year", :"#{property}_day"

        before_validation do
          send(
            "#{property}=",
            Date.new(
                send("#{property}_year").to_i,
                send("#{property}_month").to_i,
                send("#{property}_day").to_i,
            )
          )
        rescue Date::Error
          send("#{property}=", nil)
        end

        self.class_eval do
          validate :"#{property}_date_valid"

          define_method("#{property}_date_valid") do
            date = send(property)
            if date.present? && !Date.valid_date?(date.year, date.month, date.day)
              errors.add(property, :invalid_date, message: "is not a valid calendar date")
            end
          end
        end
      end
    end
  end
end
