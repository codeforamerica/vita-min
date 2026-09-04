# Run the following command with the User Ids
# bin/rails runner scripts/message_prior_year_filers.rb 111,222,333,444

# Just to get the client ids
# bin/rails runner scripts/message_prior_year_filers.rb --list-only 111,222,333,444 > client_ids.txt

require "caxlsx"
require "aws-sdk-s3"
require "tmpdir"

BUCKET = ENV["BUCKET_NAME"] || EnvironmentCredentials['MSG_PYR_BUCKET']
REGION = ENV["BUCKET_NAME_REGION"] || "us-east-1"
PREFIX = "info"

ActiveRecord::Base.logger = nil
Rails.logger = Logger.new(IO::NULL)

def parse_ids(argv)
  file_arg = argv.find { |a| a.start_with?("--file=") }
  raw =
    if file_arg
      File.read(file_arg.split("=", 2).last)
    else
      argv.reject { |a| a.start_with?("--") }.join(",")
    end

  raw.split(/[,\s]+/).map(&:strip).reject(&:empty?).map(&:to_i).uniq
end

# Excel treats a leading =, +, -, or @ as the start of a formula. Neutralize
# that in any client-supplied free text before it lands in a cell.
def excel_safe(value)
  return value unless value.is_a?(String)
  value.start_with?("=", "+", "-", "@") ? "'#{value}" : value
end

def safe_filename(filename)
  base = File.basename(filename.to_s)
  base = "unnamed_file" if base.empty? || base == "." || base == ".."
  base
end

def safe_path_within(dir, filename)
  expanded_dir = File.expand_path(dir)
  path = File.expand_path(File.join(expanded_dir, filename))
  unless path.start_with?(File.expand_path(expanded_dir) + File::SEPARATOR)
    raise "Invalid path: path traversal detected in #{filename}"
  end

  path
end

def message_sender(message)
  if message.respond_to?(:user) && message.user
    name = message.user.try(:name)
    name.presence || message.user.try(:email)
  elsif message.contact_record_type.to_s.start_with?("incoming")
    "Client"
  else
    "System"
  end
end

def all_messages_for(client)
  (
    client.outgoing_text_messages.includes(:user) +
      client.incoming_text_messages +
      client.outgoing_emails.includes(:user) +
      client.incoming_emails +
      client.incoming_portal_messages +
      SystemNote::SignedDocument.where(client: client) +
      SyntheticNote.from_client_documents(client) +
      SyntheticNote.from_outbound_calls(client) +
      SyntheticNote.from_deleted_client_documents(client)
  ).sort_by(&:datetime)
end

MATCHERS = {
  "assigned_tax_return" => ->(ids) {
    TaxReturn.where(assigned_user_id: ids).pluck(:assigned_user_id, :client_id, :updated_at)
  },
  "reassigned_tax_return" => ->(ids) {
    TaxReturnAssignment.joins(:tax_return).where(assigner_id: ids)
                       .pluck("tax_return_assignments.assigner_id", "tax_returns.client_id", "tax_return_assignments.created_at")
  },
  "note" => ->(ids) {
    Note.where(user_id: ids).pluck(:user_id, :client_id, :created_at)
  },
  "system_note" => ->(ids) {
    SystemNote.where(user_id: ids).pluck(:user_id, :client_id, :created_at)
  },
  "access_log" => ->(ids) {
    AccessLog.where(user_id: ids, record_type: "Client").pluck(:user_id, :record_id, :created_at)
  },
  "outgoing_text_message" => ->(ids) {
    OutgoingTextMessage.where(user_id: ids).pluck(:user_id, :client_id, :created_at)
  },
  "outgoing_email" => ->(ids) {
    OutgoingEmail.where(user_id: ids).pluck(:user_id, :client_id, :created_at)
  },
  "outbound_call" => ->(ids) {
    OutboundCall.where(user_id: ids).pluck(:user_id, :client_id, :created_at)
  },
  "uploaded_document" => ->(ids) {
    Document.where(uploaded_by_type: "User", uploaded_by_id: ids).pluck(:uploaded_by_id, :client_id, :created_at)
  },
}.freeze

def find_matches(user_ids)
  matches_by_client = Hash.new { |h, k| h[k] = [] }

  MATCHERS.each do |association_type, query|
    query.call(user_ids).each do |user_id, client_id, occurred_at|
      next unless client_id

      matches_by_client[client_id] << { user_id: user_id, association_type: association_type, occurred_at: occurred_at }
    end
  end

  matches_by_client
end

def build_xlsx(path, client, matches)
  intake = client.intake
  package = Axlsx::Package.new
  workbook = package.workbook

  workbook.add_worksheet(name: "Intake") do |sheet|
    if intake
      sheet.add_row(%w[Field Value])
      sheet.add_row(["Primary First Name", excel_safe(intake.primary_first_name)])
      sheet.add_row(["Primary Last Name", excel_safe(intake.primary_last_name)])
      sheet.add_row(["Primary SSN", intake.primary_ssn])
      sheet.add_row(["Primary Birth Date", intake.primary_birth_date])
      sheet.add_row(["Phone Number", intake.phone_number])
      sheet.add_row(["SMS Phone Number", intake.sms_phone_number])
      sheet.add_row(["Spouse First Name", excel_safe(intake.spouse_first_name)])
      sheet.add_row(["Spouse Last Name", excel_safe(intake.spouse_last_name)])
      sheet.add_row(["Spouse Birth Date", intake.spouse_birth_date])
      sheet.add_row(["Spouse SSN", intake.spouse_ssn])
      sheet.add_row(["Primary Consented To Service", intake.primary_consented_to_service])
      sheet.add_row(["Primary Consented To Service At", intake.primary_consented_to_service_at])
    else
      sheet.add_row(["No intake record found for this client"])
    end
  end

  workbook.add_worksheet(name: "Dependents") do |sheet|
    dependents = intake&.dependents || []
    if dependents.any?
      sheet.add_row(%w[first_name last_name ssn birth_date])
      dependents.each do |dependent|
        sheet.add_row([excel_safe(dependent.first_name), excel_safe(dependent.last_name), dependent.ssn, dependent.birth_date])
      end
    else
      sheet.add_row(["No dependents on file"])
    end
  end

  workbook.add_worksheet(name: "Communications") do |sheet|
    messages = all_messages_for(client)
    if messages.any?
      sheet.add_row(%w[datetime type sender body])
      messages.each do |message|
        sheet.add_row([message.datetime, message.contact_record_type.to_s, message_sender(message), excel_safe(message.body)])
      end
    else
      sheet.add_row(["No communications on file"])
    end
  end

  workbook.add_worksheet(name: "How this client was found") do |sheet|
    sheet.add_row(%w[user_id association_type occurred_at])
    matches.sort_by { |m| m[:occurred_at].to_s }.each do |m|
      sheet.add_row([m[:user_id], m[:association_type], m[:occurred_at]])
    end
  end

  package.serialize(path)
end

def download_client_documents(client, dir)
  documents = client.documents.where(uploaded_by_type: "Client", uploaded_by_id: client.id)
  used_filenames = {}

  documents.each do |document|
    next unless document.upload.attached?

    blob = document.upload.blob
    filename = safe_filename(blob.filename)
    filename = "#{document.id}_#{filename}" if used_filenames[filename]
    used_filenames[filename] = true

    File.open(safe_path_within(dir, filename), "wb") { |file| file.write(blob.download) }
  end
end

def upload_directory(s3_client, dir, client_id)
  key_prefix = [PREFIX, "client_#{client_id}"].reject(&:empty?).join("/")
  Dir.children(dir).each do |filename|
    s3_client.put_object(
      bucket: BUCKET,
      key: "#{key_prefix}/#{filename}",
      body: File.read(safe_path_within(dir, filename), mode: "rb"),
      )
  end
end

user_ids = parse_ids(ARGV)
if user_ids.empty?
  warn "Usage: bin/rails runner scripts/message_prior_year_filers.rb 111,222,333,444"
  warn "   or: bin/rails runner scripts/message_prior_year_filers.rb --file=/path/to/user_ids.txt"
  exit 1
end

found_user_ids = User.where(id: user_ids).pluck(:id)
missing_user_ids = user_ids - found_user_ids
warn "WARNING: no user found for id(s): #{missing_user_ids.join(", ")}" if missing_user_ids.any?

matches_by_client = find_matches(user_ids)
client_ids = matches_by_client.keys.sort
clients_by_id = Client.includes(intake: :dependents).where(id: client_ids).index_by(&:id)

warn "Resolved #{client_ids.size} distinct client(s) via: #{MATCHERS.keys.join(", ")}"

if ARGV.include?("--list-only")
  puts client_ids.join(", ")
  exit 0
end

access_key_id = EnvironmentCredentials["AWS_ACCESS_KEY_ID"]
secret_access_key = EnvironmentCredentials["AWS_SECRET_ACCESS_KEY"]

s3_client_options = { region: REGION }
s3_client_options[:credentials] = Aws::Credentials.new(access_key_id, secret_access_key) if access_key_id && secret_access_key

s3_client = Aws::S3::Client.new(s3_client_options)

client_ids.each do |client_id|
  client = clients_by_id[client_id]
  unless client
    warn "Client #{client_id} was referenced by a match but no longer exists - skipping"
    next
  end

  Dir.mktmpdir("client_#{client_id}_bundle_") do |dir|
    xlsx_path = File.join(dir, "client_#{client_id}.xlsx")
    build_xlsx(xlsx_path, client, matches_by_client[client_id])
    download_client_documents(client, dir)

    warn "Uploading client #{client_id} bundle (#{Dir.children(dir).size} file(s)) to s3://#{BUCKET}/#{PREFIX}/client_#{client_id}/"
    upload_directory(s3_client, dir, client_id)
  end
end

warn "Done. Uploaded bundles for #{client_ids.size} client(s) to s3://#{BUCKET}/#{PREFIX}/"
