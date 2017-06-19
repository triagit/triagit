# triaggit

## Sample Rules

```
version: "1.0.0"
rules:
- issue_close_outdated:
    age: 30d
- pr_close_outdated:
    age: 30d
- pr_signed_commits:
    active: true
- pr_lgtm:
    users: rdsubhas
- pr_cla:
		active: true
```
