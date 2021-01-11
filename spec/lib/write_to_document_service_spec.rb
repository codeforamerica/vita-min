require 'rails_helper'

describe WriteToDocumentService do
  subject { described_class.new(document, FakeDocumentClass) }

  let(:document) { create :document }
  let(:combine_pdf_double) { double 'combine_pdf_double' }

  before do
    fake_doc_class = Class.new do
      def self.writeable_locations
        {
            a: { y: 0, x: 0, page: 1 },
            b: { y: 0, x: 0 }
        }
      end

      def self.key
        "fake_doc_type"
      end
    end

    stub_const("FakeDocumentClass", fake_doc_class)
    allow(CombinePDF).to receive(:parse).and_return combine_pdf_double
    allow(combine_pdf_double).to receive(:to_pdf).and_return ""
  end


  describe 'instantiation' do

    it 'parses the input pdf with CombinePDF' do
      subject
      expect(CombinePDF).to have_received(:parse).with(subject.send :streamed_original)
    end
  end

  describe "#write" do
    context "when the provided location_attr does not exist" do
      it 'raises an error' do
        expect {
          subject.write(:unknown_attr, 'Raises error')
        }.to raise_error WriteToDocumentService::UnknownDocumentAttributeError
      end
    end

    context "with a location_attr that exists" do
      let(:page_writer_double_0) { double 'page_writer_double_0' }
      let(:page_writer_double_1) { double 'page_writer_double_1'}
      before do
        allow(CombinePDF).to receive(:parse).and_return combine_pdf_double
        allow(combine_pdf_double).to receive(:pages).and_return [page_writer_double_0, page_writer_double_1]
        allow(page_writer_double_0).to receive(:textbox)
        allow(page_writer_double_1).to receive(:textbox)
      end

      it 'writes to the pdf using combine_pdfs api' do
        subject.write(:a, 'Writes something')
        expect(page_writer_double_1).to have_received(:textbox).with(
          'Writes something',
          {
            text_align: "left",
            text_valign: "top",
            font_size: 12,
            height: 10,
            width: 400,
            y: 0,
            x: 0
          }
       )
      end

      context "when an explicit page number is not provided in the location_attr definition" do
        it "defaults to 0 index" do
          subject.write(:b, 'Writes something')
          expect(page_writer_double_0).to have_received(:textbox).with(
              'Writes something',
              {
                  text_align: "left",
                  text_valign: "top",
                  font_size: 12,
                  height: 10,
                  width: 400,
                  y: 0,
                  x: 0
              }
          )
        end
      end
    end
  end

  describe "#tempfile_output" do
    it 'returns a tempfile instance' do
      output = subject.tempfile_output
      expect(output).to be_a Tempfile
      expect(output.path).to include("fake_doc_type")
    end
  end
end