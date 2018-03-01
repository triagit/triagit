module Github
  class CheckPrFormatJob < ApplicationJob
    queue_as :default

    # https://developer.github.com/v3/activity/events/types/#pullrequestevent
    WEBHOOK_EVENT_NAME = 'pull_request'
    WEBHOOK_EVENT_ACTIONS = ['create', 'opened', 'edited', 'reopened']

    def perform(*args)
      begin
        event = args[0]
        return unless valid?(event)
        rule_name = args[1]
        rule = event.repo.rules[:rules].find{ |r| r[:name] == rule_name }
        # TODO: Need more sophisticated rule validation
        # i.e. whether necessary parameters for a rule was given or not
        raise unless rule
      rescue => e
        return logger.error 'Invalid argument passed', args: args
      end
      logger.info self.class.name, event: event.name, repo: event.repo.ref, rule: rule_name
      process_rule event, rule
    end

    def valid?(event)
      return event && event.is_a?(Event) &&
        event.repo.service == Constants::GITHUB &&
        event.name == WEBHOOK_EVENT_NAME &&
        WEBHOOK_EVENT_ACTIONS.include?(event.payload[:action])
    end

    def process_rule(event, rule)
      repo = event.repo
      pr_number = event.payload[:pull_request][:number]
      title = event.payload[:pull_request][:title]
      title_patterns = [ rule[:options][:match_title] ].flatten.compact
      title_matches = title_patterns.all? { |p| Regexp.new(p, "im").match?(title) }

      api_client = GithubClient.instance.new_repo_client(event.repo)
      add_label = rule[:options][:apply_label].strip
      add_comment = rule[:options][:add_comment].strip
      if title_matches
        labels_in_pr = api_client.labels_for_issue(repo.ref, pr_number).collect { |l| l.name }
        if add_label.present? && labels_in_pr.member?(add_label)
          api_client.remove_label(repo.ref, pr_number, add_label)
        end
        if add_comment.present?
          api_client.issue_comments(repo.ref, pr_number).each do |comment|
            if comment[:body].strip == add_comment
              api_client.delete_comment repo.ref, comment[:id]
            end
          end
        end
      else
        LabelHelper.add_label!(repo, pr_number, add_label)
        api_client.add_comment(repo.ref, pr_number, add_comment) if add_comment.present?
      end
    end
  end
end
