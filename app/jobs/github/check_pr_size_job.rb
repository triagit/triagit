module Github
  class CheckPrSizeJob < ApplicationJob
    queue_as :default

    def perform(args)
      rule = Rule.new(args)
      rule.execute if rule.valid?
    end

    class Rule
      # https://developer.github.com/v3/activity/events/types/#pullrequestevent
      WEBHOOK_EVENT_NAME = 'pull_request'
      WEBHOOK_EVENT_ACTIONS = ['opened', 'reopened', 'synchronize']

      include ActiveModel::Model
      include SemanticLogger::Loggable
      attr_accessor :event, :rule_name

      validates :event, :rule_name, presence: true
      validate :validate_event

      def validate_event
        unless event.name == WEBHOOK_EVENT_NAME and WEBHOOK_EVENT_ACTIONS.include?(event.payload[:action])
          errors.add :event, 'Not applicable'
        end
      end

      def repo
        event.repo
      end

      def execute
        pr = api_client.pull_request(repo.ref, pr_number)
        files_changed = pr.changed_files
        lines_changed = pr.additions + pr.deletions
        reference, key = files_changed >= lines_changed ? [files_changed, :files] : [lines_changed, :lines]
        rulecat = strategy.select { |r| r.has_key?(key) && reference <= r[key] }
        final_rule = rulecat.empty? ? strategy.last : rulecat.first
        all_rule_labels = strategy.collect { |r| r[:apply_label] if r[:apply_label].present? }.compact
        pr_diff_labels = pr.labels.collect { |l| l.name if all_rule_labels.include? l.name }.compact - [final_rule[:apply_label]]
        pr_diff_labels.each { |l|
          LabelActionJob.perform_later repo: repo, rule_name: rule_name,
            issue_or_pr: pr_number, action: "delete", label: l
        }
        LabelActionJob.perform_later repo: repo, rule_name: rule_name,
          issue_or_pr: pr_number, action: "add", label: final_rule[:apply_label]

        if final_rule[:add_comment].present?
          CommentActionJob.perform_later repo: repo, rule_name: rule_name,
            issue_or_pr: pr_number, action: "add_or_update", comment: final_rule[:add_comment]
        else
          CommentActionJob.perform_later repo: repo, rule_name: rule_name,
            issue_or_pr: pr_number, action: "delete"
        end
      end

      def pr_number
        event.payload[:pull_request][:number].to_i
      end

      def rule
        @rule ||= event.repo.rules[:rules].find{ |r| r[:name] == rule_name }
      end

      def strategy
        rule[:options][:strategy]
      end

      def api_client
        @api_client ||= GithubClient.instance.new_repo_client(event.repo)
      end
    end
  end
end
