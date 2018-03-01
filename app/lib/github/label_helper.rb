module Github
    class LabelHelper
        def self.add_label!(repo, pr_number, label_to_add)
            api_client = GithubClient.instance.new_repo_client(repo)
            labels_in_pr = api_client.labels_for_issue(repo.ref, pr_number).collect { |l| l.name }
            if ! labels_in_pr.include? label_to_add 
                api_client.add_labels_to_an_issue(repo.ref, pr_number, [label_to_add])
            end
        end
    end
end