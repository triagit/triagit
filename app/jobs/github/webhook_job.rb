module Github
  class WebhookJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(Event) && args[0].repo.service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      event = args[0]
      repo = event.repo
      logger.info self.class.name, repo: repo.ref, event: event.name
    end
  end
end
