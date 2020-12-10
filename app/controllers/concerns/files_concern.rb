module FilesConcern
  def transient_storage_url(attachment, disposition: nil)
    # Create a quickly-expiring URL for a given ActiveStorage attachment.
    # When using S3 storage, the URL is not on our domain, protecting users from possible Javascript in the storage object.
    #
    # Expiration is controlled via `Rails.application.config.active_storage.service_urls_expire_in`
    #
    # Use this instead of rails_blob_url because rails_blob_url creates long-lasting URLs which redirect to transient URLs.
    # We want no long-lasting URLs.

    # ActiveStorage's #service_url requires us to set `host`;  see https://stackoverflow.com/questions/51110789/activestorage-service-url-rails-blob-path-cannot-generate-full-url-when-not-u
    ActiveStorage::Current.set(host: request.base_url) do
      attachment.service_url(disposition: disposition || :inline) # :inline is the default for #service_url
    end
  end
end
