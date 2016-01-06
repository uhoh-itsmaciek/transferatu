require "bundler"
Bundler.require

require "./lib/initializer"
require "clockwork"

$stdout.sync = true

module Clockwork
  # The scheduler is broken.

  # Every 15 minutes, it enqueues every job waiting for the current wall clock hour

  # This task takes more than 15 minutes, because creating a transfer requires
  # resolving database credentials from shogun or yobuko first. Sometimes it will take
  # more than an hour, and jobs will be lost.

  # Eventually this ends up with a job starting at 4.50 and ending at 6.05, thus
  # skipping over the jobs marked to run at 5pm.

  # We mitigated this by parallelisng our calls to shogun, but when shogun's database is slow
  # the time taken crawls back up to an hour and we're back to dropped jobs.

  # We need to unpack task creation from callback resolution to be able to schedule
  # every job quickly, but ultimately we should not be limiting the jobs to the ones
  # that need to run on this hour, but any job that needs to run in the past.


  every(15.minutes, "run-scheduled-transfers") do
    resolver = Transferatu::ScheduleResolver.new
    processor = Transferatu::ScheduleProcessor.new(resolver)
    manager =  Transferatu::ScheduleManager.new(processor)

    scheduled_time = Time.now

    # Let's play: Schedule past transfers due 2 hours ago first.

    # Theoretically, running this again should not re-enqueue transfers
    # because the earlier code was marked to run every 15 minutes.


    (-2..0).each do |offset|
      Pliny.log(task: 'run-scheduled-transfers', scheduled_for: scheduled_time) do
        manager.run_schedules(scheduled_time + offset.hours)
      end
    end
  end
end
