module Transferatu
  class Schedule < Sequel::Model
    plugin :timestamps
    plugin :paranoid

    many_to_one :group
    one_to_many :transfers

    def mark_executed
      update(last_scheduled_at: Time.now)
    end

    # Schedules that are expected to start a transfer at the given
    # time and have not started any transfers in the twelve hours
    # before this time
    def_dataset_method(:pending_for) do |time, limit: 250|
      self.with_sql(<<-EOF, time: time, limit: limit)
WITH pending AS (
  SELECT
    -- Take the current time, convert it into the schedule's timezone to get the local hour
    -- (Local_Hour - Scheduled_hour) + 48 mod 24 to get how many hours ago it was.
    s.*, mod(extract(hour from (:time at time zone timezone)::timestamptz)::smallint-hour+48, 24) as due_hours_ago
  FROM
    schedules s
  WHERE
    ARRAY[extract(dow from (:time at time zone timezone)::timestamptz)::smallint] && dows AND (
      s.last_scheduled_at IS NULL
      OR s.last_scheduled_at < (timestamptz :time - interval '12 hours')
    ) AND s.deleted_at IS NULL
)
SELECT pending.* FROM pending
WHERE due_hours_ago < 12
ORDER BY due_hours_ago DESC, last_scheduled_at nulls first
LIMIT
  :limit
EOF
    end
  end
end
