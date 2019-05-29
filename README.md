# Developer Scoreboard

This is a small API to determine an organization's github contributions in the past week (Sunday-Saturday) and declare a winner.

| Type of Contribution | Points |
| :-: | :-: |
| Pull Request | 9 |
| Pull Request Review | 3 |
| Pull Request Comment | 1 |

### Run locallly

1. ```git clone https://github.com/rkstarnerd/scoreboard.git```
2. ```bundle install```
3. ```rails s```

### Request
``` http://localhost:3000/scoreboard/org/:org_name ```
