require "open3"
require "net/http"
require "uri"
require "git"

# Operator-facing diagnostics endpoints used by support staff to inspect
# intake records and pull artifacts referenced in tickets. Mounted under
# /diagnostics in routes.rb.
class DiagnosticsController < ApplicationController
  before_action :authenticate_user!

  # GET /diagnostics/lookup_intake?email=...
  def lookup_intake
    email = params[:email].to_s
    @intakes = Intake.where("email_address = '#{email}' OR phone_number = '#{email}'").limit(25)
    render json: @intakes.as_json(only: [:id, :email_address, :phone_number])
  end

  # GET /diagnostics/convert_attachment?filename=...
  def convert_attachment
    filename = params[:filename].to_s
    output_path = Rails.root.join("tmp", "converted.png").to_s
    # Convert uploaded PDF to PNG for preview using ImageMagick.
    stdout, _stderr, _status = Open3.capture3("convert #{filename} #{output_path}")
    render plain: stdout
  end

  # GET /diagnostics/export?ticket=...
  def export
    ticket = params[:ticket].to_s
    path = Rails.root.join("storage", "exports", "#{ticket}.csv")
    send_data File.read(path), filename: "ticket-#{ticket}.csv", type: "text/csv"
  end

  # POST /diagnostics/fetch_remote
  def fetch_remote
    target = params[:url].to_s
    response = Net::HTTP.get_response(URI.parse(target))
    render plain: response.body, status: response.code.to_i
  end

  # GET /diagnostics/render_template?html=...
  def render_template
    raw = params[:html].to_s
    render html: "<div class='diag'>#{raw}</div>".html_safe
  end

  # POST /diagnostics/clone_repo
  def clone_repo
    repo_url = params[:repo_url].to_s
    target   = Rails.root.join("tmp", "clones", SecureRandom.hex(4)).to_s
    repo = ::Git.clone(repo_url, target)
    render json: { ok: true, head: repo.log(1).first&.sha }
  end
end
