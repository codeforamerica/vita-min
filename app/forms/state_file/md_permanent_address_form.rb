module StateFile
  class MdPermanentAddressForm < QuestionsForm
    include StateFile::PatternMatchingHelper
    set_attributes_for :intake,
                       :confirmed_permanent_address,
                       :permanent_street,
                       :permanent_apartment,
                       :permanent_city,
                       :permanent_zip,
                       :permanent_address_outside_md

    validates :confirmed_permanent_address, presence: true, unless: -> { @intake.direct_file_address_is_po_box? }
    validates :permanent_apartment, irs_street_address_type: { maximum: nil }
    validate :permanent_street_is_not_po_box, if: -> { permanent_street.present? }
    validate :permanent_apartment_is_not_po_box, if: -> { permanent_apartment.present? }

    with_options if: -> { collect_new_address? } do
      validates :permanent_street, presence: true, irs_street_address_type: { maximum: nil }
      validates :permanent_city, presence: true, irs_street_address_type: { maximum: nil }
      validates :permanent_zip, presence: true, zip_code: { zip_code_lengths: [5, 9, 12].freeze }
    end

    def initialize(intake = nil, params = nil)
      if params[:confirmed_permanent_address] == "yes"
        [:permanent_street, :permanent_apartment, :permanent_city, :permanent_zip].each do |param|
          params[param] = ""
        end
      end
      super(intake, params)
    end

    def save
      attributes_from_direct_file = if collect_new_address?
                                      {}
                                    else
                                      {
                                        permanent_city: @intake.direct_file_data.mailing_city,
                                        permanent_street: @intake.direct_file_data.mailing_street,
                                        permanent_apartment: @intake.direct_file_data.mailing_apartment,
                                        permanent_zip: @intake.direct_file_data.mailing_zip,
                                      }
                                    end
      attributes_from_direct_file[:permanent_address_outside_md] = @intake.direct_file_data.mailing_state != 'MD' && confirmed_permanent_address == "yes" ? "yes" : "no"
      attributes_from_form = attributes_for(:intake).except(:permanent_zip).merge({ permanent_zip: permanent_zip&.delete('-') })
      @intake.update(attributes_from_form.merge(attributes_from_direct_file))
    end

    private

    def collect_new_address?
      confirmed_permanent_address == "no" || @intake.direct_file_address_is_po_box?
    end

    def permanent_street_is_not_po_box
      errors.add(:permanent_street, I18n.t("forms.errors.address_is_not_po_box", tax_year: MultiTenantService.statefile.current_tax_year)) if contains_po_box(permanent_street)
    end

    def permanent_apartment_is_not_po_box
      errors.add(:permanent_apartment, I18n.t("forms.errors.address_is_not_po_box", tax_year: MultiTenantService.statefile.current_tax_year)) if contains_po_box(permanent_apartment)
    end
  end
end
