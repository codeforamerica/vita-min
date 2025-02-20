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
        self.define_method("#{property}_month") do
          self.instance_variable_get("@#{property}_month") || send(property)&.month
        end
        self.define_method("#{property}_year") do
          self.instance_variable_get("@#{property}_year") || send(property)&.year
        end
        self.define_method("#{property}_day") do
          self.instance_variable_get("@#{property}_day") || send(property)&.day
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
        attr_writer :"#{property}_month", :"#{property}_year", :"#{property}_day"

        before_validation do
          month_to_set = self.instance_variable_get("@#{property}_month")
          day_to_set = self.instance_variable_get("@#{property}_day")
          year_to_set = self.instance_variable_get("@#{property}_year")

          if year_to_set.present? && month_to_set.present? && day_to_set.present?
            send("#{property}=", Date.new(year_to_set.to_i, month_to_set.to_i, day_to_set.to_i))
          end
        rescue Date::Error
          send("#{property}=", nil)
        end

        self.class_eval do
          validate :"#{property}_date_valid"

          define_method("#{property}_date_valid") do
            date = send(property)
            if date.present? && !Date.valid_date?(date.year, date.month, date.day)
              errors.add(:date_of_contribution, :invalid_date, message: I18n.t("activerecord.errors.models.az321_contribution.attributes.date_of_contribution.inclusion"))
            end
          end
        end
      end
    end
  end
end
