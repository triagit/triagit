module Github
  class LabelActionJob < ApplicationJob
    queue_as :default

    def perform(args)
      rule = Rule.new(args)
      rule.execute if rule.valid?
    end

    class Rule
      ACTIONS = %w(add delete)

      include ActiveModel::Model
      include SemanticLogger::Loggable
      attr_accessor :repo, :rule_name, :issue_or_pr, :action, :label

      validates :repo, :rule_name, :issue_or_pr, :action, :label, presence: true
      validates :action, inclusion: { in: ACTIONS }
      validate :validate_repo

      def validate_repo
        errors.add(:repo, 'must be a Repo model') unless repo.is_a?(Repo)
      end

      def execute
        self.send(action) if self.respond_to?(action)
      end

      def add
        labels_in_pr = api_client.labels_for_issue(repo.ref, issue_or_pr).collect { |l| l.name }
        unless labels_in_pr.include? label
          api_client.add_labels_to_an_issue(repo.ref, issue_or_pr, [label])
        end
      end

      def delete
        api_client.remove_label(repo.ref, issue_or_pr, label)
      end

      def api_client
        @api_client ||= GithubClient.instance.new_repo_client(repo)
      end
    end
  end
end
