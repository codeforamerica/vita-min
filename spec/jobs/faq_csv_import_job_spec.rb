require 'rails_helper'

describe FaqCsvImportJob do
  describe ".parse" do
    let(:en_csv) do
      <<~CSV
        Section Key,Updated,Section Name (EN),Question Key,Question (EN),Answer (EN)
        stimulus,No,Stimulus,will_there_be_another_stimulus_payment,ignored,ignored
        stimulus,Yes,Stimulus,how_do_i_get_the_stimulus_payments,How do I get it,"This is how
        To get it"
      CSV
    end

    let(:es_csv) do
      <<~CSV
        Section Key,Updated,Section Name (ES),Question Key,Question (ES),Answer (ES)
        stimulus,No,Stimulus,will_there_be_another_stimulus_payment,ignored,ignored
        stimulus,Yes,Stimulus,how_do_i_get_the_stimulus_payments,¿How do I get it?,"Este es
        como you get it"
      CSV
    end

    it "parses English properly" do
      expect(
        described_class.parse(en_csv, :en)
      ).to(
        eq(
          {
            stimulus: {
              title: "Stimulus",
              will_there_be_another_stimulus_payment: { unchanged: true },
              how_do_i_get_the_stimulus_payments: {
                question: "How do I get it",
                answer_html: "<p>This is how</p><p>To get it</p>",
              }
            }
          }
        )
      )
    end

    it "parses Spanish properly" do
      expect(
        described_class.parse(es_csv, :es)
      ).to(
        eq(
          {
            stimulus: {
              title: "Stimulus",
              will_there_be_another_stimulus_payment: { unchanged: true },
              how_do_i_get_the_stimulus_payments: {
                question: "¿How do I get it?",
                answer_html: "<p>Este es</p><p>como you get it</p>",
              }
            }
          }
        )
      )
    end
  end

  describe ".updated_translations" do
    let(:new_content) do
      {
        stimulus: {
          will_there_be_another_stimulus_payment: { unchanged: true },
          how_many_stimulus_payments_were_there: {
            question: "how many??",
            answer_html: "500"
          }
        }
      }
    end
    let(:initial_data) do
      {
        faq: {
          question_groups: {
            stimulus: {
              will_there_be_another_stimulus_payment: {
                question: "Well?",
                answer_html: "Nah",
              },
              how_many_stimulus_payments_were_there: {
                question: "How many",
                answer_html: "5",
              },
              what_about_a_question_we_remove: {
                question: "trash this question?",
                answer_html: "yup",
              }
            }
          }
        }
      }
    end

    it "returns new translation data with the provided data" do
      expect(
        described_class.updated_translations(initial_data, "faq.question_groups", new_content)
      ).to eq({
                faq: {
                  question_groups: {
                    stimulus: {
                      how_many_stimulus_payments_were_there: {
                        question: "how many??",
                        answer_html: "500",
                      },
                      will_there_be_another_stimulus_payment: {
                        question: "Well?",
                        answer_html: "Nah",
                      },
                    }
                  }
                }
              })
    end
  end
end
