require 'aws-sdk-bedrockruntime'
require 'json'
require 'base64'
require "mini_magick"
require "tempfile"
require "English"
require "open3"

module BedrockDocScreener
  MODEL_ID = 'us.anthropic.claude-haiku-4-5-20251001-v1:0'.freeze
  REGION = 'us-east-1'.freeze
  SUPPORTED_MEDIA_TYPES = %w[
    image/png
    image/jpeg
    image/gif
    image/bmp
    image/tiff
    application/pdf
  ].freeze
  # image formats Bedrock accepts as it is, anything else gets converted to jpeg
  BEDROCK_IMAGE_TYPES = %w[
    image/png
    image/jpeg
    image/gif
    image/webp
  ].freeze
  MAX_RAW_IMAGE_SIZE = 3.7.megabytes
  # Bedrock rejects images over 8000px on any side, so we resize them
  MAX_IMAGE_DIMENSION = 8000
  # Haiku 4.5 downscales anything over 1568px itself, so shrinking to this loses nothing
  RESIZED_IMAGE_DIMENSION = 2000
  MIN_RESIZED_IMAGE_DIMENSION = 500

  PDF_RENDER_DPI = 200
  MAX_IMAGES_PER_REQUEST = 20
  MAX_REQUEST_SIZE = 25_000_000
  MAX_REQUEST_IMAGE_BYTES = MAX_REQUEST_SIZE - 1_000_000
  MAX_SCREENED_PAGES = 20

  MAX_TOKENS = 1024
  # Prefilling the assistant turn makes the model continue from inside the JSON object,
  # so it can't open with a sentence or wrap the JSON in a markdown fence
  JSON_PREFILL = "{".freeze

  class UnsupportedMediaTypeError < StandardError; end
  class ImageTooLargeError < StandardError; end

  class InvalidResponseError < StandardError
    attr_reader :raw_response_json

    def initialize(message = nil, raw_response_json: nil)
      super(message)
      @raw_response_json = raw_response_json
    end
  end

  PROMPT_VERSION = "v1".freeze

  def self.prompt_for(document_type:, page_context: nil)
    <<~PROMPT
      Clients are uploading documents and you need to verify the validity of the document using these rules:
         1) If the photo is a poor quality image (poorly lit, blurry, cropped & missing information, pixelated screen etc.) 
            so much so that it renders the document illegible, then add "unreadable" to document_quality_issues array.
         2) If the document does not fit any of the doc types in the available-doc-types list,
            then set suggested_document_type=null and set matches_doc_type_verdict="fail".
            If the document seems to be a valid document, readable and the selected document type matches,
            then set document_quality_issues=["N/A"] and matches_doc_type_verdict="pass".
         3) If it does not appear to match the stated doc type (in this case #{document_type}) 
            but does match another type in the available-doc-types list, then set matches_doc_type_verdict="fail" 
            and set suggested_document_type to the key of the doc-type that matches.
            and include the doc-types that might be match in the explanation field by their label name.
         4) If the document is expired, then add "expired" to document_quality_issues array.
         5) If the document is fake ONLY if it is glaringly obvious (for example if it is labeled as 'SAMPLE', etc),
            then add "potentially_fake" to document_quality_issues array.
            Do not flag documents as potentially fake based on subtle concerns or suspicions.
         6) matches_doc_type_verdict should ONLY be determined by whether the document type matches, 
            not by document_quality_issues such as being expired, potentially fake, or unreadable.
            A document can pass the type match even if it has quality issues.
         7) If there is another reason that the document is not valid, then set document_quality_issues="other"
         8) Do not include any keys other than "matches_doc_type_verdict", "suggested_document_type", "document_quality_issues", "explanation" and "confidence"
         9) matches_doc_type_verdict should only be "pass" or "fail"
         10) Always set suggested_document_type to the key of the doc type that best matches the document.
            If none of the available doc types are a good fit, set suggested_document_type=null.
            Do not force a selection if there is no clear match.
         11) document_quality_issues is an array that can include: "unreadable", "expired", "potentially_fake", "other"
             Multiple issues can be present at the same time.
         12) "confidence" must be between 0.0 and 1.0. "confidence" must be one of these discrete values based on how clear the assessment is:
              - 0.95: Near-certain. The document clearly matches (or clearly does not match) the suggested document type with no ambiguity.
              - 0.8:  High confidence. Strong evidence supports your verification decision; unlikely to be wrong but not absolute.
              - 0.5:  Moderate confidence. The document probably is (or is not) the suggested type, but there are features that create uncertainty.
              - 0.2:  Low confidence. Verification is a best guess; the document has ambiguous characteristics that make it difficult to confirm or reject the suggested type.
      
      Document Type Guidelines:
      - IDs (like driver's licenses, state IDs, passports) are any documents that have a photo of the person, their name, 
        their birthday, and are issued by a state or federal government.

      available-doc-types: #{available_doc_types}

      Selected document type: #{document_type}
      #{page_context}
      Return ONLY valid JSON with this exact schema:
      {
        "matches_doc_type_verdict": "pass" | "fail",
        "suggested_document_type": "key from available-doc-types" | null,
        "document_quality_issues": ["unreadable" | "expired" | "potentially_fake" | "other"],
        "explanation": "Brief 1-2 sentence explanation of reason. Explain why invalid if so. The briefer the better, please do not be redundant.",
        "confidence": number between 0.0-1.0
      }
    PROMPT
  end

  def self.available_doc_types
    # should always match @document_type_options in hub/document controller,
    # since those are the only types available in the drop down
    available_doc_types = [DocumentTypes::Identity, DocumentTypes::SsnItin] + (DocumentTypes::ALL_TYPES - DocumentTypes::IDENTITY_TYPES - DocumentTypes::SECONDARY_IDENTITY_TYPES)
    available_doc_types.map do |d|
      result = { key: d.key, label: d.label }
      result[:description] = d.description if d.respond_to?(:description)
      result
    end
  end

  def self.screen_document!(document:)
    raise "Document has no upload attached" unless document.upload.attached?

    media_type = document.upload.content_type
    raise UnsupportedMediaTypeError, "Unsupported media type: #{media_type}" unless SUPPORTED_MEDIA_TYPES.include?(media_type)

    if media_type == "application/pdf"
      screen_pdf!(document.upload, document_type: document.document_type)
    else
      request_screening!(
        images: [prepare_image(document.upload.download)],
        user_prompt: prompt_for(document_type: document.document_type)
      )
    end
  end

  def self.request_screening!(images:, user_prompt:)
    body_hash = construct_bedrock_payload(images: images, user_prompt: user_prompt)

    response = invoke_bedrock_model(body_hash.to_json)

    raw_response_json = JSON.parse(response.body.read)

    if raw_response_json["stop_reason"] == "max_tokens"
      raise InvalidResponseError.new(
        "Bedrock response was cut off after #{MAX_TOKENS} tokens",
        raw_response_json: raw_response_json
      )
    end

    # the response continues from the prefill, so it doesn't include the opening brace
    generated_text = JSON_PREFILL + extract_text_from_response(raw_response_json)

    result_json = begin
      parse_strict_json!(generated_text)
    rescue InvalidResponseError => e
      raise InvalidResponseError.new(e.message, raw_response_json: raw_response_json)
    end

    [result_json, raw_response_json]
  end

  def self.screen_pdf!(upload, document_type:)
    with_pdf_file(upload) do |pdf_path|
      total_pages = pdf_page_count(pdf_path)
      chunks = []
      skips = []

      pages = render_pdf_pages(pdf_path, 1, [total_pages, MAX_SCREENED_PAGES].min).filter_map do |page_number, png_data|
        [page_number, prepare_image(png_data)]
      rescue ImageTooLargeError, MiniMagick::Error, MiniMagick::Invalid => e
        skips << { pages: [page_number], error: e }
        nil
      end

      group_pages_into_requests(pages).each do |request_pages|
        screen_pdf_chunk(request_pages, total_pages: total_pages, document_type: document_type, chunks: chunks, skips: skips)
      end

      raise skips.first[:error] if chunks.empty? && skips.any?
      raise "pdf produced no pages" if chunks.empty?

      merged_result = merge_chunk_results(chunks).merge(
        "total_pages" => total_pages,
        "screened_pages" => chunks.flat_map { |chunk| chunk[:pages] }.sort,
        "page_limit_reached" => total_pages > MAX_SCREENED_PAGES,
        "skipped" => skips.map { |skip| { "pages" => skip[:pages], "reason" => "#{skip[:error].class}: #{skip[:error].message}" } },
        "chunks" => chunks.map { |chunk| { "pages" => chunk[:pages], "result" => chunk[:result] } }
      )
      raw_response_json = { "chunks" => chunks.map { |chunk| { "pages" => chunk[:pages], "response" => chunk[:raw_response_json] } } }

      [merged_result, raw_response_json]
    end
  end

  def self.group_pages_into_requests(pages)
    pages.each_with_object([[]]) do |page, requests|
      request = requests.last
      request_bytes = request.sum { |_page_number, image| image[:base64_data].bytesize }
      page_bytes = page.last[:base64_data].bytesize

      if request.any? && (request.size >= MAX_IMAGES_PER_REQUEST || request_bytes + page_bytes > MAX_REQUEST_IMAGE_BYTES)
        requests << []
      end
      requests.last << page
    end.reject(&:empty?)
  end

  def self.screen_pdf_chunk(pages, total_pages:, document_type:, chunks:, skips:)
    return if pages.empty?

    page_numbers = pages.map(&:first)

    result_json, raw_response_json = request_screening!(
      images: pages.map(&:last),
      user_prompt: prompt_for(
        document_type: document_type,
        page_context: page_context_for(page_numbers, total_pages: total_pages, previous_chunks: chunks)
      )
    )
    chunks << { pages: page_numbers, result: result_json, raw_response_json: raw_response_json }
  rescue Aws::BedrockRuntime::Errors::ValidationException, InvalidResponseError => e
    if pages.size > 1
      pages.each_slice((pages.size / 2.0).ceil) do |half|
        screen_pdf_chunk(half, total_pages: total_pages, document_type: document_type, chunks: chunks, skips: skips)
      end
    else
      skips << { pages: page_numbers, error: e }
    end
  end

  def self.page_context_for(page_numbers, total_pages:, previous_chunks:)
    return if page_numbers.size >= total_pages

    context = "These images are pages #{page_numbers.first}-#{page_numbers.last} of a #{total_pages}-page upload. " \
              "The upload may contain several different documents, and a document may continue onto pages not shown here. " \
              "Assess only the pages shown.\n"
    return context if previous_chunks.empty?

    summaries = previous_chunks.map do |chunk|
      result = chunk[:result]
      "- Pages #{chunk[:pages].first}-#{chunk[:pages].last}: verdict=#{result['matches_doc_type_verdict']}, " \
        "suggested_document_type=#{result['suggested_document_type'] || 'null'}, explanation: #{result['explanation']}\n"
    end

    context +
      "Earlier pages of this upload were already assessed:\n#{summaries.join}" \
      "If the pages shown continue a document from those earlier pages, treat them as part of that document.\n"
  end

  def self.merge_chunk_results(chunks)
    results = chunks.map { |chunk| chunk[:result] }
    passing_results = results.select { |result| result["matches_doc_type_verdict"] == "pass" }
    deciding_results = passing_results.presence || results

    primary_result = deciding_results.max_by { |result| result["confidence"].to_f }
    quality_issues = deciding_results.flat_map { |result| Array(result["document_quality_issues"]) }.uniq
    quality_issues -= ["N/A"] if (quality_issues - ["N/A"]).any?

    primary_result.merge("document_quality_issues" => quality_issues)
  end

  # The stored content_type can disagree with the actual bytes (e.g. a png named .jpg
  # attached with identify: false), and Bedrock rejects the request when they don't match.
  # So we detect the type from the bytes and convert anything Bedrock can't take.
  def self.prepare_image(raw_data)
    media_type = Marcel::MimeType.for(StringIO.new(raw_data))

    unless BEDROCK_IMAGE_TYPES.include?(media_type) && within_bedrock_limits?(raw_data)
      raw_data = ensure_safe_image_size(raw_data)
      media_type = "image/jpeg"
    end

    {
      media_type: media_type,
      base64_data: Base64.strict_encode64(raw_data)
    }
  end

  def self.within_bedrock_limits?(binary_data)
    return false if binary_data.bytesize > MAX_RAW_IMAGE_SIZE

    image = MiniMagick::Image.read(binary_data)
    image.width <= MAX_IMAGE_DIMENSION && image.height <= MAX_IMAGE_DIMENSION
  end

  # Converts to jpeg and shrinks to fit within Bedrock's limits
  def self.ensure_safe_image_size(binary_data)
    image = MiniMagick::Image.read(binary_data)
    image.format "jpeg"
    image.combine_options do |c|
      c.colorspace "sRGB"
      c.resize "#{RESIZED_IMAGE_DIMENSION}x#{RESIZED_IMAGE_DIMENSION}>"
      c.quality "85"
    end

    result = image.to_blob

    while result.bytesize > MAX_RAW_IMAGE_SIZE
      if [image.width, image.height].max / 2 < MIN_RESIZED_IMAGE_DIMENSION
        raise ImageTooLargeError, "Image is still #{result.bytesize} bytes after resizing to #{image.width}x#{image.height}"
      end

      image.resize "50%"
      result = image.to_blob
    end

    result
  end

  def self.construct_bedrock_payload(images:, user_prompt:)
    {
      anthropic_version: "bedrock-2023-05-31",
      max_tokens: MAX_TOKENS,
      messages: [{
                   role: "user",
                   content: [
                     *images.map do |img|
                       { type: "image", source: { type: "base64", media_type: img[:media_type], data: img[:base64_data] } }
                     end,
                     { type: "text", text: user_prompt }
                   ]
                 },
                 { role: "assistant", content: JSON_PREFILL }]
    }
  end

  def self.invoke_bedrock_model(body_payload)
    client = Aws::BedrockRuntime::Client.new(region: REGION)
    client.invoke_model(
      body: body_payload,
      model_id: MODEL_ID,
      content_type: 'application/json',
      accept: 'application/json'
    )
  end

  def self.extract_text_from_response(response)
    Array(response['content'])
      .select { |content| content['type'] == 'text' }
      .map { |content| content['text'].to_s.strip }
      .reject(&:empty?)
      .join("\n")
  end

  def self.parse_strict_json!(text)
    s = text.to_s

    blocks = s.scan(/```(?:json)?\s*(\{.*?\})\s*```/m)
    if blocks.any?
      json_str = blocks.last.first
      return JSON.parse(json_str)
    end

    cleaned = s.strip
    cleaned = cleaned.sub(/\A```(?:json)?\s*/i, "").sub(/\s*```\z/, "").strip
    JSON.parse(cleaned)
  rescue JSON::ParserError => e
    leading_object = parse_leading_object(cleaned) if cleaned
    return leading_object if leading_object

    raise InvalidResponseError, "Bedrock did not return valid JSON. \n Error: #{e.message} \n Output: #{text.inspect}"
  end

  # The model sometimes adds a note after the object, so try each closing brace,
  # from the last one back, until the text up to it parses
  def self.parse_leading_object(text)
    start = text.index("{")
    return unless start

    closing_braces = (start...text.length).select { |i| text[i] == "}" }
    closing_braces.reverse_each do |finish|
      return JSON.parse(text[start..finish])
    rescue JSON::ParserError
      next
    end
    nil
  end

  def self.with_pdf_file(upload)
    Tempfile.create(["upload", ".pdf"]) do |pdf|
      pdf.binmode
      pdf.write(upload.download)
      pdf.flush

      yield pdf.path
    end
  end

  def self.pdf_page_count(pdf_path)
    output, status = Open3.capture2("pdfinfo", pdf_path, err: File::NULL)
    page_count = output[/^Pages:\s+(\d+)/, 1] if status.success?
    raise "failed to read pdf page count (pdfinfo exit code #{status.exitstatus})" unless page_count

    page_count.to_i
  end

  def self.render_pdf_pages(pdf_path, first_page, last_page)
    Dir.mktmpdir do |tmpdir|
      output_prefix = File.join(tmpdir, "page")
      success = system("pdftoppm", "-png", "-r", PDF_RENDER_DPI.to_s, "-f", first_page.to_s, "-l", last_page.to_s,
                       pdf_path, output_prefix, out: File::NULL, err: File::NULL)
      raise "failed to convert pdf pages to images (pdftoppm exit code #{$CHILD_STATUS&.exitstatus})" unless success

      Dir.glob(File.join(tmpdir, "page-*.png"))
         .map { |png_path| [File.basename(png_path)[/(\d+)\.png$/, 1].to_i, File.binread(png_path)] }
         .sort_by(&:first)
    end
  end
end
