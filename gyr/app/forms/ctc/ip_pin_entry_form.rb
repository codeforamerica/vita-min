module Ctc
  class IpPinEntryForm < QuestionsForm
    set_attributes_for :intake, :primary_ip_pin, :spouse_ip_pin

    attr_accessor :dependents_attributes
    
    validates :primary_ip_pin, presence: true, ip_pin: true, if: -> { @intake.has_primary_ip_pin_yes? }
    validates :spouse_ip_pin, presence: true, ip_pin: true, if: -> { @intake.has_spouse_ip_pin_yes? }

    def dependents
      @intake.assign_attributes(dependents_attributes: dependents_attributes.to_h)
      @intake.dependents.select { |dep| dep.has_ip_pin_yes? }
    end

    def valid?
      form_valid = super
      dependents_valid = dependents.map { |d| d.valid?(:ip_pin_entry_form) }
      form_valid && !dependents_valid.include?(false)
    end

    def save
      @intake.update!(attributes_for(:intake).merge(dependents_attributes: dependents_attributes.to_h))
    end
  end
end
