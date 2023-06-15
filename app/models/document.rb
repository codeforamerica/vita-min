# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  archived             :boolean          default(FALSE), not null
#  contact_record_type  :string
#  display_name         :string
#  document_type        :string           not null
#  person               :integer          default("unfilled"), not null
#  uploaded_by_type     :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :bigint
#  contact_record_id    :bigint
#  documents_request_id :bigint
#  intake_id            :bigint
#  tax_return_id        :bigint
#  uploaded_by_id       :bigint
#
# Indexes
#
#  index_documents_on_client_id                                  (client_id)
#  index_documents_on_contact_record_type_and_contact_record_id  (contact_record_type,contact_record_id)
#  index_documents_on_documents_request_id                       (documents_request_id)
#  index_documents_on_intake_id                                  (intake_id)
#  index_documents_on_tax_return_id                              (tax_return_id)
#  index_documents_on_uploaded_by_type_and_uploaded_by_id        (uploaded_by_type,uploaded_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (documents_request_id => documents_requests.id)
#  fk_rails_...  (tax_return_id => tax_returns.id)
#
require "mini_magick"

class Document < ApplicationRecord
  ACCEPTED_FILE_TYPES = [:browser_native_image, :other_image, :document]
  belongs_to :intake, optional: true
  belongs_to :client, touch: true
  belongs_to :contact_record, polymorphic: true, optional: true
  belongs_to :tax_return, optional: true
  belongs_to :uploaded_by, polymorphic: true, optional: true

  validates_presence_of :client
  validates_presence_of :upload
  validate :tax_return_belongs_to_client
  validate :tax_return_present_sometimes
  validate :tax_return_absent_sometimes
  validate :upload_must_have_data
  validate :upload_must_be_readable, if: -> { document_type == DocumentTypes::UnsignedForm8879.key }
  validate :unsigned_form_8879_file_type
  # Permit all existing document types plus two historical ones
  validates_presence_of :document_type
  validates :document_type, inclusion: { in: DocumentTypes::ALL_TYPES.map(&:key) + ["Requested", "F13614C / F15080 2020"] }, allow_blank: true

  before_save :set_display_name

  enum person: { unfilled: 0, primary: 1, spouse: 2 }, _prefix: :person

  default_scope { order(created_at: :asc) }

  scope :of_type, ->(type) { where(document_type: type) }
  scope :active, ->() { where(archived: false) }
  scope :archived, ->() { where(archived: true) }

  after_save do
    # Skip AnalyzeJob when initially creating .heic files, since we will analyze them after JPG conversion
    upload.blob.analyzed = true if is_heic? && !upload.blob.persisted?
  end

  after_create_commit do
    uploaded_by.is_a?(Client) ? InteractionTrackingService.record_incoming_interaction(client) : InteractionTrackingService.record_internal_interaction(client)

    HeicToJpgJob.perform_later(id) if is_heic?
  end
  after_save_commit { SearchIndexer.refresh_filterable_properties([client_id]) }
  after_destroy_commit { SearchIndexer.refresh_filterable_properties([client_id]) }

  # has_one_attached needs to be called after defining any callbacks that access attachments, like
  # the HEIC conversion; see https://github.com/rails/rails/issues/37304
  has_one_attached :upload
  validates :upload, file_type_allowed: true, if: -> { upload.present? }

  def upload=(value)
    if value.is_a?(ActionDispatch::Http::UploadedFile)
      @file_for_validations = value.tempfile
    elsif value.is_a?(Hash) && value.key?(:io) && (value[:io].is_a?(File) || value[:io].is_a?(Tempfile))
      @file_for_validations = value[:io]
    end
    super(value)
  end

  def is_pdf?
    upload&.content_type == "application/pdf"
  end

  def is_heic?
    upload&.filename&.extension_without_delimiter&.downcase == "heic"
  end

  def document_type_class
    DocumentTypes::ALL_TYPES.find { |doc_type_class| doc_type_class.key == document_type }
  end

  def document_type_label
    document_type_class&.label || document_type
  end

  def set_display_name
    return if display_name.present?

    self.display_name = upload.attachment.filename
  end

  def convert_heic_upload_to_jpg!
    image = MiniMagick::Image.read(upload.download)

    jpg_image = image.format("jpg")

    upload.attach(io: File.open(jpg_image.path), filename: "#{display_name}.jpg", content_type: "image/jpeg")
    update!(display_name: upload.attachment.filename)
  end

  def uploaded_by_name_label
    if uploaded_by.is_a? User
      uploaded_by.name || ""
    elsif uploaded_by.is_a? Client
      I18n.t("hub.documents.index.client_doc")
    else
      I18n.t("hub.documents.index.system_generated_doc")
    end
  end

  def confirmation_needed?
    document_type.in? [DocumentTypes::FinalTaxDocument.key, DocumentTypes::UnsignedForm8879.key]
  end

  private

  def tax_return_belongs_to_client
    errors.add(:tax_return_id, I18n.t("forms.errors.tax_return_belongs_to_client")) unless tax_return.blank? || tax_return.client == client
  end

  def tax_return_present_sometimes
    if document_type_class&.must_be_associated_with_tax_return && tax_return.blank?
      errors.add(:tax_return_id, I18n.t("validators.must_be_associated_with_tax_return", document_type: document_type))
    end
  end

  def tax_return_absent_sometimes
    if document_type_class&.must_not_be_associated_with_tax_return && tax_return.present?
      errors.add(:tax_return_id, I18n.t("validators.must_not_be_associated_with_tax_return", document_type: document_type))
    end
  end

  def upload_must_have_data
    if upload.attached? && upload.blob.byte_size.zero?
      errors.add(:upload, I18n.t("validators.file_zero_length"))
    end
  end

  def upload_must_be_readable
    if @file_for_validations.present? && is_pdf?
      begin
        PDF::Reader.new(@file_for_validations)
      rescue PDF::Reader::MalformedPDFError
        errors.add(:upload, I18n.t("validators.pdf_file_corrupted"))
      end
    end
  end

  def unsigned_form_8879_file_type
    if upload.attached? && document_type == DocumentTypes::UnsignedForm8879.key && !upload.content_type.in?(%w(application/pdf))
      errors.add(:upload, I18n.t("validators.pdf_file_type", document_type: document_type))
    end
  end
end
