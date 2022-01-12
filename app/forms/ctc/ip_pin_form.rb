module Ctc
  class IpPinForm < QuestionsForm
    set_attributes_for :intake, :has_primary_ip_pin, :has_spouse_ip_pin
    set_attributes_for :confirmation, :no_ip_pins

    attr_accessor :dependents_attributes
    validates :no_ip_pins, at_least_one_or_none_of_the_above_selected: true

    def dependents
      @intake.dependents
    end

    def save
      attributes = {}

      attributes[:has_primary_ip_pin] = has_primary_ip_pin || "no"
      if attributes[:has_primary_ip_pin] == "no" || no_ip_pins == "yes"
        attributes[:has_primary_ip_pin] = "no"
        attributes[:primary_ip_pin] = nil
      end

      attributes[:has_spouse_ip_pin] = has_spouse_ip_pin || "no"
      if attributes[:has_spouse_ip_pin] == "no" || no_ip_pins == "yes"
        attributes[:has_spouse_ip_pin] = "no"
        attributes[:spouse_ip_pin] = nil
      end

      if dependents_attributes.present?
        dependents_attributes.values.each do |dependent_attributes|
          dependent_attributes[:has_ip_pin] = "no" if dependent_attributes[:has_ip_pin].nil?
          if dependent_attributes[:has_ip_pin] == "no" || no_ip_pins == "yes"
            dependent_attributes[:ip_pin] = nil
          end
        end

        attributes[:dependents_attributes] = dependents_attributes
      end

      @intake.update!(attributes)
    end

    def at_least_one_selected
      no_ip_pins == "yes" ||
        has_primary_ip_pin == "yes" ||
        has_spouse_ip_pin == "yes" ||
        (dependents_attributes&.values || []).any? { |attributes| attributes["has_ip_pin"] == "yes" }
    end
  end
end
