require 'rails_helper'

describe FaqCsvImportJob do
  describe ".parse" do
    let(:en_csv) do
      <<~CSV
        Section Key,Updated,Question Key,Question (EN),Answer (EN)
        stimulus,No,will_there_be_another_stimulus_payment,ignored,ignored
        stimulus,Yes,how_do_i_get_the_stimulus_payments,How do I get it,This is how
      CSV
    end

    it "parses English properly" do
      expect(
        described_class.parse(en_csv)
      ).to(
        eq(
          { stimulus:
              {
                will_there_be_another_stimulus_payment: { unchanged: true },
                how_do_i_get_the_stimulus_payments: {
                  question: "How do I get it",
                  answer_html: "<p>This is how</p>",
                }
              }
          }
        )
      )
    end
  end

  describe ".update_translations" do
    it "returns new translation data with the provided data" do
      expect(described_class.update_yaml(
        base_key: "views.public_pages.faq.question_groups",
        initial_data: {
          stimulus: {
            will_there_be_another_stimulus_payment: {
              question: "Well?",
              answer_html: "Nah",
            },
            how_many_stimulus_payments_were_there: {
              question: "How many",
              answer_html: "5",
            }
          }
        },
        new_data: {
          stimulus: {
            will_there_be_another_stimulus_payment: { unchanged: true },
            how_many_stimulus_payments_were_there: {
              question: "how many??",
              answer_html: "500"
            }
          }
        }
      ).to eq({

              })
    end
  end
end
