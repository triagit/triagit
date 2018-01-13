class ApplicationJob < ActiveJob::Base
  include ActiveJobRetryControlable
  before_perform do |_job|
    ActiveRecord::Base.clear_active_connections!
  end
  rescue_from(Exception) do |exception|
    raise exception if retry_limit_exceeded?
    retry_job(wait: rand(60..120) + 3**attempt_number)
  end

  # For resque / resque-scheduler compatibility
  def self.queue
    queue_name
  end
end
