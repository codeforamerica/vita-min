require 'csv'

class TextExperiment
  def self.run
    treatments.each do |treatment|
      file = Rails.root.join("lib", "text_experiment", treatment[:filename])
      rows = CSV.read(file)
      rows[1..].each do |row|
        client = Client.find_by(id: row[0])
        unless client.present?
          print "cant find client #{row[0]}"
          next
        end
        archived_intake = Archived::Intake2021.find_by(client_id: row[0])
        unless archived_intake.present?
          print "cant find intake for client #{row[0]}"
          next
        end
        first_name = archived_intake.primary_first_name
        ClientMessagingService.send_text_message(
          client: client,
          user: nil,
          body: treatment[:message] % { name: first_name }
        )
        print "."
      end
    end

  end


  def self.treatments
    [
        {
            filename: "_messages_22-benefits.csv",
            message: "Hello %{name}, this is GetCTC — you used our service to claim CTC or stimulus payments last year. If you haven’t filed yet this year, you might be eligible to claim cash benefits. It’s free and easy to file to get your money. Visit https://www.getyourrefund.org/22-benefits (Automated message, do not reply)"
        },
        {
            filename: "_messages_22-file.csv",
            message: "Hello %{name}, this is GetCTC — you used our service to claim CTC or stimulus payments last year. If you haven’t filed yet this year, you might be eligible to claim cash benefits. It’s free and easy to file to get your money. Visit https://www.getyourrefund.org/22-file (Automated message, do not reply)"
        },
        {
            filename: "_messages_diy_s=22-claim.csv",
            message: "Hello %{name}, this is GetCTC — you used our service to claim CTC or stimulus payments last year. If you haven’t filed yet this year, you might be eligible to claim cash benefits. It’s free and easy to file to get your money. Visit https://www.getyourrefund.org/diy?s=22-claim (Automated message, do not reply)"
        },
        {
            filename: "_messages_benefits-22.csv",
            message: "Hello %{name}, this is GetCTC — you used our service to claim CTC or stimulus payments last year. If you haven’t filed yet this year, you might be eligible to claim cash benefits. It’s free and easy to file to get your money. Visit https://www.getyourrefund.org/benefits-22 (Automated message, do not reply)"
        },
        {
            filename: "_messages_file-22.csv",
            message: "Hello %{name}, this is GetCTC — you used our service to claim CTC or stimulus payments last year. If you haven’t filed yet this year, you might be eligible to claim cash benefits. It’s free and easy to file to get your money. Visit https://www.getyourrefund.org/file-22 (Automated message, do not reply)",
        },
        {
            filename: "_messages_diy_s=claim-22.csv",
            message: "Hello %{name}, this is GetCTC — you used our service to claim CTC or stimulus payments last year. If you haven’t filed yet this year, you might be eligible to claim cash benefits. It’s free and easy to file to get your money. Visit https://www.getyourrefund.org/diy?s=claim-22 (Automated message, do not reply)"
        },
        {
            filename: "_messages_ctc-22.csv",
            message: "Hello %{name}, this is GetCTC — you used our service to claim CTC or stimulus payments last year. If you haven’t filed yet this year, you might be eligible to claim cash benefits. It’s free and easy to file to get your money. Visit https://www.getctc.org/ctc-22 (Automated message, do not reply)"
        }
    ]
  end
end