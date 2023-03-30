# Aggregator Import Failure Notifier

Checks for failed aggregator imports and then sends slack notification to the BMLT-Enabled `root-status` channel.

## What does this do?

This creates a lambda that gets triggered whenever the aggregator ECS task state changes, It then checks if the desired 
status is stopped so we know that the task has ended. We then hit the root server endpoint of aggregator and check if any of 
last successful import times is less than the ECS task start time. If it is then it sends a slack notification to the 
BMLT-Enabled `root-status` channel.

## Why?

I had previously created a php script that accomplishes this similarly but was never really happy with it. It ran on a cron
and wasn't precise enough. Adding to 47 bot would of been more of the same. With this it gets triggered as soon as the import
is done and we will know right away if a import failed.

## Setup

To install clone this repo, then from the terraform directory. You then should login to console and set the hook in the 
lambdas env variable. Setting it in the variable can be dangerous because if you then commit the state file you would have
 also commited the hook. Then run.

```
terraform init
```

This will initialize the terraform. now run.

```
terraform plan
```

This will zip the lambda using the archive data source, As well as give you the plan for what the apply stage will 
perform. If all looks good you can now run.

```
terraform apply
```

## TODO:
If a root server fails an import, it would be interesting to look into the possibility of pulling the cloudwatch logs and 
attaching the error message along with the slack notification. Most of the time they are just connection errors. 
