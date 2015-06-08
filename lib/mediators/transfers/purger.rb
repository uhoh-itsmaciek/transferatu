module Transferatu::Mediators::Transfers
  class Purger < Transferatu::Mediators::Base
    def initialize(transfer:)
      @transfer = transfer
    end

    def call
      unless @transfer.deleted_at
        raise ArgumentError, "Can't purge non-deleted transfer"
      end
      if @transfer.to_type != 'gof3r'
        raise ArgumentError, "Can only purge gof3r transfers"
      end
      s3_uri = URI.parse(@transfer.to_url)
      bucket_name = s3_uri.hostname.split('.').first
      object_id = s3_uri.path[1..-1]

      s3 = Aws::S3::Client.new(access_key_id: Config.aws_access_key_id,
                               secret_access_key: Config.aws_secret_access_key,
                               region: 'us-east-1')
      s3.delete_object(bucket: bucket_name, key: object_id)
      @transfer.update(purged_at: Time.now)
    end
  end
end
