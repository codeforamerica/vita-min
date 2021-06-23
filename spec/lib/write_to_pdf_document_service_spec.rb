require 'rails_helper'

describe WriteToPdfDocumentService do
  subject { described_class.new(document, FakeDocumentClass) }

  let(:document) { create :document, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf") }

  before do
    fake_doc_class = Class.new do
      def self.writeable_locations
        {
            a: { y: 195, x: 200 },
            b: { y: 0, x: 0, page: 1 }
        }
      end

      def self.key
        "fake_doc_type"
      end
    end

    stub_const("FakeDocumentClass", fake_doc_class)
  end

  context "without stubbing CombinePDF" do
    describe "#write" do
      context "when the provided location_attr does not exist" do
        it 'raises an error' do
          expect {
            subject.write(:unknown_attr, 'Raises error')
          }.to raise_error WriteToPdfDocumentService::UnknownDocumentAttributeError
        end
      end

      it "writes to the pdf file" do
        subject.write(:a, "Some info")
        output_file = subject.tempfile_output
        reader = PDF::Reader.new(output_file)
        expect(reader.pages[0].text).to include "Some info"
      end

      context "passing params to write" do
        let(:combine_pdf_double) { double }
        let(:page_writer_double_0 ) { double }
        let(:page_writer_double_1) { double }
        before do
          allow(CombinePDF).to receive(:parse).and_return combine_pdf_double
          allow(combine_pdf_double).to receive(:pages).and_return [page_writer_double_0, page_writer_double_1]
          allow(page_writer_double_0).to receive(:textbox)
          allow(page_writer_double_1).to receive(:textbox)
        end

        context "when the provided location_attr does not exist" do
          it 'raises an error' do
            expect {
              subject.write(:unknown_attr, 'Raises error')
            }.to raise_error WriteToPdfDocumentService::UnknownDocumentAttributeError
          end
        end

        context "when the page attribute is not defined on the location_attr" do
          it "infers that the page is 0" do
            subject.write(:a, "Some text")
            expect(page_writer_double_0).to have_received(:textbox).with(
                "Some text",
                {
                    text_align: "left",
                    text_valign: "top",
                    font_size: 12,
                    height: 10,
                    width: 400,
                    y: 195,
                    x: 200
                }
            )
          end
        end

        context "when the page attribute is defined in the location_attr" do
          it "uses the page provided and removes it from hash to send to combinepdf" do
            subject.write(:b, "Some text")
            expect(page_writer_double_1).to have_received(:textbox).with(
                "Some text",
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
end
