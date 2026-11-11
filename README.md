# Terraform Bedrock IAM

A Terraform project that creates a least-privilege IAM role for calling one Amazon Bedrock model.

## What it creates
- An IAM policy that allows only `bedrock:InvokeModel`, and only on the Amazon Nova Micro model
- An IAM role with that policy attached
- A trust policy so that only my IAM user can assume the role
- An output with the role's ARN

## How to run it
```bash
terraform init
terraform plan
terraform apply
terraform destroy   # optional cleanup
```
Needs AWS credentials configured and an IAM user named in the trust policy. Change the user name in `main.tf` to match yours.

## How I tested it
I added a profile that assumes the role, then ran my Bedrock script and an S3 command with it:
- The Bedrock script worked
- `aws s3 ls` failed with AccessDenied, because the role has no S3 permissions

## What I learned
- Least privilege really worked: the script ran through the `bedrock-nova-micro-role` role, but the same role was denied access to S3, which the admin user can do.
- One small mistake in a config file can stop everything. I had added quotation marks around the role ARN, and the AWS CLI said the ARN was invalid. When I checked the file with `cat ~/.aws/config`, I spotted the quotes and removed them.
- Reading the last lines of an error message first saves a lot of time. The long traceback was noise, and the real message was at the bottom.
