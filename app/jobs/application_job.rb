class ApplicationJob < ActiveJob::Base
  before_perform do |_job|
    ActiveRecord::Base.clear_active_connections!
  end

  # For resque / resque-scheduler compatibility
  def self.queue
    queue_name
  end
end
