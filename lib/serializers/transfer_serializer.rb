module Transferatu::Serializers
  class Transfer < Base
    structure(:default) do |transfer|
      {
        uuid: transfer.uuid,
        num:  transfer.transfer_num,

        from_name: transfer.from_name,
        from_type: transfer.from_type,
        from_url:  transfer.from_url,
        to_name:   transfer.to_name,
        to_type:   transfer.to_type,
        to_url:    transfer.to_url,
        options:   transfer.options,
        log_token: transfer.logplex_token,

        source_bytes:    transfer.source_bytes,
        processed_bytes: transfer.processed_bytes,
        succeeded:       transfer.succeeded,

        created_at:  transfer.created_at,
        started_at:  transfer.started_at,
        canceled_at: transfer.canceled_at,
        updated_at:  transfer.updated_at,
        finished_at: transfer.finished_at,
        deleted_at:  transfer.deleted_at,
        purged_at:   transfer.purged_at
      }
    end
  end
end
