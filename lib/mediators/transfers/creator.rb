module Transferatu
  module Mediators::Transfers
    class InvalidTransferError < StandardError; end

    class Creator < Mediators::Base
      def initialize(group:, type:, from_url:, to_url:, options:)
        @group = group
        @type = type
        @from_url = from_url
        @to_url = to_url
        @options = options
      end

      def call
        # TODO: this is a really crufty way to handle autogenerated URLs
        if @type =~ /:gof3r$/
          if @to_url == 'auto'
            bucket = Config.s3_bucket_name
            key = "#{URI.encode(@group.name)}/#{Time.new.utc.iso8601}"
            @to_url = "https://#{bucket}.s3.amazonaws.com/#{key}"
          else
            raise InvalidTransferError, "to_url must be 'auto' for transfers targeting gof3r"
          end
        end
        if @type =~ /:pg_restore$/
          begin
            to_uri = URI.parse(@to_url)
            if to_uri.scheme.nil? || to_uri.scheme != 'postgres'
              raise InvalidTransferError, "to_url must be valid postgres URL for pg_restore"
            end
          rescue URI::InvalidURIError
            raise InvalidTransferError, "invalid to_url for pg_restore"
          end
        end
        if @type =~ /^pg_dump:/
          begin
            from_uri = URI.parse(@from_url)
            if from_uri.scheme.nil? || from_uri.scheme != 'postgres'
              raise InvalidTransferError, "from_url must be valid postgres URL for pg_dump"
            end
          rescue URI::InvalidURIError
            raise InvalidTransferError, "invalid to_url for pg_dump"
          end
        end
        begin
          Transfer.create(group: @group, type: @type,
                          from_url: @from_url, to_url: @to_url,
                          options: @options)
        rescue StandardError => e
          puts e.inspect
        end
      end
    end
  end
end
