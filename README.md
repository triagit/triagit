# triagit

## Design Thought Process

* Rails
  - Official github octokit.rb client, first-class citizen
  - Automatic pagination with handling of rate limits, built-in ETag and caching, etc
  - ActiveJob, resque, UI dashboard, essential for background jobs
  - ActiveRecord with transparent and programmatic caching
  - And rest of everything we normally need (aka can be done with any language but easily integrated) - ORM, asset pipeline, user sign in oauth libraries, templating, etc etc
  - Given all the above, think Rails is a good choice to begin with
* Yet,
  - GitHub, User login, Website, etc - are all developed as individual pieces with separate namespaces with *nothing shared* architecture, except the bare minimum database models
  - The bare minimum models must NOT become fat models, use activeattr/MVVM styles for additional logic
  - Always should be straight forward to separate out individual parts into separate apps
  - Duplication is better than premature sharing

## Rules

* close/flag outdated issue
* close/flag outdated pr
* delete outdated/PR-merged branches
* require signed commits
* require lgtm/approval from N accounts
* commmit message must be of given format
* must have signed CLA
* auto-assign label upon creation
* auto-assign label upon diff paths
* auto-assign reviewer upon creation
* diff size must be less than X
* must have a label (e.g. Ready for release, etc)
* must have label for certain diff paths (e.g. Migration approved)
* move project boards based on labels
* auto approve PRs from certain teams/users

## Other Requirements

* Org-wide rules
* Dashboard (subsequently users, roles, permissions)

## Model Overview

```
User: email, handle
Account: email, billing, installation, type (github/gitlab/etc)
	AccountUser: account <> user
	Token
	Repo: rules, settings, ...
		Event
```

## TODO

* What if same git repo in multiple integrations/accounts?
  * +if using soft deletes (i.e. account status=inactive/blocked)
* User installs sync - Cleaning up removed/phantom installs
