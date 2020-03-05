# Tomato Import Failure Notifier

Checks for failed tomato imports and then sends slack notification to the BMLT-Enabled `root-status` channel.

a cloudwatch event rule triggers the lambda when a tomato ecs task state changes.
