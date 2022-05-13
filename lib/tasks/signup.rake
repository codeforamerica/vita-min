namespace :signup do
  desc 'Deal with messaging signups'
  # rake signup:delete_messaged ctc_2020_open_message
  task delete_messaged: [:environment] do
    puts ARGV
    ARGV.each { |a| task a.to_sym do ; end }
    attribute = "#{ARGV[1]}_sent_at"
    puts attribute
    if Signup.new.respond_to?(attribute)
      Signup.where.not(attribute => nil).delete_all
    end
  end

  # rake signup:send ctc_2020_open_message 1000
  task send_messages: [:environment] do
    ARGV.each { |a| task a.to_sym do ; end }
    message_name = ARGV[1].to_s
    batch_size = ARGV[2].to_i || nil
    raise "Batch size is required" unless batch_size.present?
    if Signup.new.respond_to?("#{message_name}_sent_at")
      SendSignupMessageJob.perform_later(message_name, batch_size)
    end
  end
end