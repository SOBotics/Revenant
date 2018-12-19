# Revenant

Revenant is a tool which uses a list from [Tagdor](https://github.com/SOBotics/Tagdor) and the [Stack Exchange API](https://api.stackexchange.com) to detect burninated tags that have re-appeared on questions.

# Installation

0. `git clone https://github.com/SOBotics/revenant`
1. Install dependencies `bundle install`
2. Configure `settings.yml` to look like:

```yaml
chatx_username: SE account username
chatx_password: SE account password
api_key: API Key from stackapps.com
```

# Usage

This runs as 1-off check to find all tags that have risen from burnination. It will post the output in room 167908 on chat.stackoverflow.com. It looks for tags only on Stack Overflow, not on any other Stack Exchange sites.

I recommend setting up a cron job or some sort of regularly timed running of this script to ensure no tags rise from burnination.
