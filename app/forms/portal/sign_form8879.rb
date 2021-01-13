module Portal
  class SignForm8879 < Form
    attr_accessor :primary_accepts_terms, :primary_confirms_identity, :ip, :transaction_failed
    validate :terms_accepted
    validate :identity_confirmed

    def initialize(tax_return, params = {})
      @tax_return = tax_return
      super(params)
    end

    def sign
      return false unless valid?

      return true if ActiveRecord::Base.transaction do
        record_primary_signer_information_on_tax_return
        change_tax_return_status
        @tax_return.save!
        create_signed_8879
      end

      errors.add(:transaction_failed) && false
    end

    private

    def create_signed_8879
      unsigned8879 = @tax_return.documents.find_by(document_type: DocumentTypes::Form8879.key)
      @document_writer = WriteToPdfDocumentService.new(unsigned8879, DocumentTypes::Form8879)
      @document_writer.write(:primary_signature, @tax_return.client.legal_name)
      @document_writer.write(:primary_signed_on, Date.today.strftime("%m/%d/%Y"))

      tempfile = @document_writer.tempfile_output
      @tax_return.documents.create!(
        client: @tax_return.client,
        document_type: DocumentTypes::CompletedForm8879.key,
        display_name: "Taxpayer Signed #{@tax_return.year} 8879",
        upload: {
          io: tempfile,
          filename: "Signed-f8879.pdf",
          content_type: "application/pdf",
          identify: false
        }
      )
      @tax_return.client.set_attention_needed
    end

    def record_primary_signer_information_on_tax_return
      @tax_return.primary_signed_at = DateTime.now
      @tax_return.primary_signed_ip = ip
    end

    def change_tax_return_status
      @tax_return.status = :file_ready_to_file
    end

    private
    def terms_accepted
      errors.add(:primary_accepts_terms, :blank) unless primary_accepts_terms == "yes"
    end

    def identity_confirmed
      errors.add(:primary_confirms_identity, :blank) unless primary_confirms_identity == "yes"
    end
  end

  class NotReadyToSignError < StandardError; end
  class AlreadySignedError < StandardError; end
end