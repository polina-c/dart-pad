# DartPad Probes

Tests in this folder do not run on presubmit, but run on schedule
to verify prod instances of the service.

## How to get alerted on failures

Documentation is declaring: "Notifications for scheduled workflows are sent to the user who initially created the workflow."

See https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/monitoring-workflows/notifications-for-workflow-runs

More discussion is here: https://stackoverflow.com/questions/62304258/github-actions-notifications-on-workflow-failure

## How to run the tests

```
cd pkgs/dart_services/
dart test test/probes
```
