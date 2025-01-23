# Story
We have been using Terraform on our AWS deployments quite successfully. However we are noticing that the initial usage seems to be limiting as some of the code is constructed in a way that we need to amend the code every time when we want to reflect the changes from the external systems.

# Problem statement
We have been creating user specific S3 buckets for our researchers by explicitly defining the list of the usernames and then declaring S3 buckets resources based on this list. Initially it was working fine and users were quite happy. But now with the increased demand we are seeing this process became a bottleneck. We want to change the approach where the buckets are created dynamically based on our people directory system where the actual list of active users is available by accessing REST API (http://people-directory:8080/active that returns bare JSON array of strings that represent usernames). You are assigned for this task to implement this transition from a fixed list of users to the external source based.

# Expected output
Updated main.tf code that is generating S3 buckets dynamically based on the output from the REST API above. You can add extra files and modules if required but do not overcomplicate.

# Bonus points
- Plan on migrating from old setup to new setup (How and when to run? What happens to the TF state file?)
- Since the source now is dynamic how do we keep the buckets in S3 in sync with the external source? (e.g. if new user is added it is expected that the bucket is created automatically)
- Again on keeping users and their buckets in sync: since this list form REST API is dynamic, and if people would quite or leave the company, the would disappear from the list. What would happen to the TF code when apply happens? What could be done to support this corner case?
- Permissions for users to the respective S3 buckets