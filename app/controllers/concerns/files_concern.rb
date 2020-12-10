module FilesConcern
  def transient_storage_url(attachment, disposition: nil)
    # Create a quickly-expiring URL for a given ActiveStorage attachment.
    # When using S3 storage (e.g., in production), ActiveStorage generates URLs that are not our domain. This protects us
    # from a cross-site scripting issue if browsers were to render HTML & JavaScript from the attachment.
    # See e.g. https://resources.infosecinstitute.com/topic/exploit-xss-image/
    #
    # Expiration is controlled via `Rails.application.config.active_storage.service_urls_expire_in`
    #
    # Use this instead of #rails_blob_url because #rails_blob_url creates long-lasting URLs which redirect to transient URLs.
    # We want no long-lasting URLs because those are not revocable when we remove users' accounts.

    # In dev & test, we use ActiveStorage's local disk backend. In that case, #service_url requires us to set `host`;
    # see https://stackoverflow.com/questions/51110789/activestorage-service-url-rails-blob-path-cannot-generate-full-url-when-not-u
    ActiveStorage::Current.set(host: request.base_url) do
      attachment.service_url(disposition: disposition || :inline) # :inline is the default for #service_url
    end
  end
end
