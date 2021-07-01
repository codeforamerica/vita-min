module WithDependentsAttributes
  extend ActiveSupport::Concern

  included do
    validate :dependents_attributes_required_fields
    validate :ip_pins_format

    attr_accessor :dependents_attributes
  end

  def dependents
    unless @dependents_attributes.present?
      return @client.present? ? @client.intake.dependents : Dependent.none
    end

    intake = Intake::GyrIntake.new
    @dependents_attributes&.each do |_, v|
      next if v["_destroy"] == "1"

      v.delete :_destroy # delete falsey _destroy value on reload to initialize dependent again
      intake.dependents.new formatted_dependent_attrs(v)
    end
    intake.dependents
  end

  private

  def formatted_dependents_attributes
    @dependents_attributes&.map { |k, v| [k, formatted_dependent_attrs(v)] }.to_h
  end

  def dependents_attributes_required_fields
    empty_fields = []
    @dependents_attributes&.each do |_, v|
      vals = HashWithIndifferentAccess.new v
      next if vals["_destroy"] == "1"

      required_dependents_attributes.each do |attribute|
        if attribute.to_sym == :birth_date
          empty_fields << "birth_date" if [vals["birth_date_year"], vals["birth_date_month"], vals["birth_date_year"]].any?(&:blank?)
        else
          empty_fields << attribute if vals[attribute].blank?
        end
      end
    end
    if empty_fields.present?
      error_message = I18n.t("forms.errors.dependents", attrs: empty_fields.uniq.map { |field| I18n.t("forms.errors.dependents_attributes.#{field}") }.join(", "))
      errors.add(:dependents_attributes, error_message)
    end
  end

  def formatted_dependent_attrs(attrs)
    if attrs[:birth_date_month] && attrs[:birth_date_month] && attrs[:birth_date_year]
      attrs[:birth_date] = "#{attrs[:birth_date_year]}-#{attrs[:birth_date_month]}-#{attrs[:birth_date_day]}"
    end
    attrs.except!(:birth_date_month, :birth_date_day, :birth_date_year)
  end

  def ip_pins_format

  end
end