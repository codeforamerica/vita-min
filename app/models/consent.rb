# == Schema Information
#
# Table name: consents
#
#  id                               :bigint           not null, primary key
#  disclose_consented_at            :datetime
#  global_carryforward_consented_at :datetime
#  ip                               :inet
#  relational_efin_consented_at     :datetime
#  use_consented_at                 :datetime
#  user_agent                       :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  client_id                        :bigint           not null
#
# Indexes
#
#  index_consents_on_client_id  (client_id)
#
class Consent < ApplicationRecord
  belongs_to :client
  has_one :intake, through: :client

  def update_or_create_optional_consent_pdf
    consent_pdf = OptionalConsentPdf.new(self)
    ClientPdfDocument.create_or_update(
      output_file: consent_pdf.output_file,
      document_type: consent_pdf.document_type,
      client: client,
      filename: consent_pdf.output_filename
    )
  end

  def update_or_create_f15080_vita_disclosure_pdf
    consent_pdf = F15080VitaConsentToDisclosePdf.new(self.intake)
    ClientPdfDocument.create_or_update(
      output_file: consent_pdf.output_file,
      document_type: consent_pdf.document_type,
      client: client,
      filename: consent_pdf.output_filename
    )
  end
end
