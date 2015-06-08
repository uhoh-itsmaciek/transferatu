module Transferatu::Mediators::Groups
  class Purger < Transferatu::Mediators::Base
    def initialize(group:)
      @group = group
    end

    def call
      unless @group.deleted_at
        raise ArgumentError, "Can't purge non-deleted group"
      end
      Transferatu::Transfer.where(finished_at: nil, group: @group).all.each do |t|
        t.cancel
      end

      Transferatu::Transfer.where(group: @group, deleted_at: nil)
        .update(deleted_at: Time.now)

      Transferatu::Transfer.purgeable(deleted_before: Time.now)
        .where(group: @group).all.each do |t|
        Transferatu::Mediators::Transfers::Purger.run(transfer: t)
      end
    end
  end
end
