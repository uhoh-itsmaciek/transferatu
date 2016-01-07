require "bundler"
Bundler.require

require "./lib/initializer"
require "clockwork"

$stdout.sync = true

module Clockwork
  # Dump 250 jobs in the queue every 5 minutes
  # Any scheduled job that should have happened in the last 12 hours,
  # but has not been run in the last 12 hours is eligible

  every(5.minutes, "run-scheduled-transfers") do
    resolver = Transferatu::ScheduleResolver.new
    processor = Transferatu::ScheduleProcessor.new(resolver)
    manager =  Transferatu::ScheduleManager.new(processor)

    Pliny.log(task: 'run-scheduled-transfers', scheduled_for: scheduled_time) do
      manager.run_schedules(Time.now, batch_size: 250)
    end
  end
end
