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
  - And we know, Ruby is not screaming fast, but in the beginning horizontal scaling is good enough, and immediately adding all requests into a queue and processing them later with fault tolerance works great even without scale

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

## Models Overview

```
User: email, handle
Account: email, billing, installation, type (github/gitlab/etc)
	AccountUser: account <> user
	Token (ephemeral)
	Repo: rules, settings, ...
		Event
```

```
TriageRule
  GitHub::Rule::CloseOutdatedIssues
  GitHub::Rule::CloseOutdatedPrs
  ...

  <Service>::Rule::<inflection>
    docs, examples, etc
    custom attributes for each rule
      since 30days to close, label to apply when closing, etc
    rules process/respond to events
      treat everything as an event, even a simple cron trigger
    no event interactions to begin with
      unidirectional, fail with link to sign CLA, CLA signed, passes
    same event can be processed by multiple rules
      e.g. PR checks, cron triggers, etc
    fan-in/fan-out?
      what if multiple rules have to update a single PR?
      what's the unit of exection? can everything be async?
    queuing
      event can have an immediate action (yellow PR)
      and also a delayed/queued action (red/green PR)
      two classes or one class accepting two events?
    throttling, retrying
      based on payment plans, github call limits, rule/repo priority, etc
    usage tracking, auditing
      non-retryable execution errors must be displayed in account UI
    deprecation, versioning

    new(repo, attributes, like since=30, etc)
    validate(whether attributes are fine, account rule payment/access, etc)
    execute(with event)
```

## TODO

* What if same git repo in multiple integrations/accounts?
  * +if using soft deletes (i.e. account status=inactive/blocked)
* User installs sync - Cleaning up removed/phantom installs
