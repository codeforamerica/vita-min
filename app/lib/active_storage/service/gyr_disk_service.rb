require "active_storage/service/disk_service"

class ActiveStorage::Service::GyrDiskService < ActiveStorage::Service::DiskService
  def upload(key, io, checksum: nil, **)
    instrument :upload, key: key, checksum: checksum do
      # This line from the real DiskService fails on certain docker + kernel combos, so we will do it a different way so our CircleCI builds work:
      # IO.copy_stream(io, make_path_for(key))

      # We should be able to remove this if CircleCI starts using a different linux kernel version (currently 5.4.0-1060-aws)

      if io.respond_to?(:path)
        File.write(make_path_for(key), File.read(io.path))
      else
        IO.copy_stream(io, make_path_for(key))
      end

      ensure_integrity_of(key, checksum) if checksum
    end
  end
end
