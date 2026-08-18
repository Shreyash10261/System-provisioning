# Experiment 2 - Advanced Infrastructure as Code

This project implements the topology required by the laboratory guide:

```text
Internet
   |
Internet gateway
   |
VPC (10.0.0.0/16)
   |-- Public subnet (10.0.1.0/24): web-1, web-2 [HTTP: public; SSH: admin CIDR only]
   `-- Private subnet (10.0.2.0/24): db-1 [MySQL 3306: web security group only]
```

The configuration creates the guide's 11 initial resources: VPC, internet gateway, two subnets, public route table and association, two security groups, two web instances, and one database instance. The web instance count is controlled by `count`, and the database security group references the web security group, forming an explicit least-privilege dependency.

## Before starting

1. Install Terraform 1.6+, AWS CLI v2, Git, VS Code, an SSH client, and Graphviz.
2. Configure AWS credentials for an IAM user allowed to manage EC2 and VPC resources. Confirm the account and region with:

   ```bash
   aws sts get-caller-identity
   aws configure get region
   ```

3. In the AWS Console, create an EC2 key pair in the target region and save its `.pem` file outside this project.
4. Select a current **Amazon Linux** AMI in that same region. Amazon publishes distinct AMI IDs per region, so do not copy an AMI ID from a tutorial for another region.

## Configure your values

Copy the example values, then edit only the new local file:

```bash
cp terraform.tfvars.example terraform.tfvars
curl https://checkip.amazonaws.com
```

Set `admin_cidr` to the returned public IP followed by `/32`, plus your key-pair name and AMI ID. For example, `198.51.100.25` becomes `198.51.100.25/32`. Never use `0.0.0.0/0` for SSH. The configuration defaults to `t3.micro`; use a different instance type only if AWS lists it as Free Tier eligible for your account.

`terraform.tfvars` is ignored by Git so it will not store your machine-specific settings in a repository.

## Run the experiment

From this directory, execute the following in order:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform graph | dot -Tsvg > dependency-graph.svg
terraform plan -out=tfplan
terraform apply tfplan
```

When Terraform completes, record the outputs:

```bash
terraform output
```

You should see two public web IP addresses and one private database IP. Creation runs network resources first; the two web VMs can then be created in parallel. The database SG cannot be made until the web SG exists because its MySQL rule references that group.

## Verification for the observation table

Wait one or two minutes after apply for the web start-up script to install Apache, then run:

```bash
bash scripts/verify.sh
```

This gives the positive web-reachability result (HTTP 200 from each web VM). Inspect the plan/apply log and the generated `dependency-graph.svg` for the creation-order observation.

To record the remaining security observations:

| Test | How to perform it | Expected result |
| --- | --- | --- |
| SSH restriction | From a network whose public IP is **not** `admin_cidr`, run `ssh -o ConnectTimeout=10 ec2-user@<web-public-ip>`. | Times out or is refused. |
| Database isolation | From your laptop, try `nc -vz -w 10 <db-private-ip> 3306`. | Fails: the address is private and no inbound rule allows your laptop. |
| Tier-to-tier access | SSH to a web VM, then run `nc -vz -w 10 <db-private-ip> 3306`. | Network access is allowed by the DB security group. A successful TCP test also needs MySQL/MariaDB listening on the DB VM. |
| Reusability | Run `terraform plan -var='web_count=3'`. | Exactly one additional `web[2]` instance is planned. |
| Teardown order | Run `terraform destroy` after recording observations. | Instances are deleted before subnets/VPC. |

The lab topology deliberately has no NAT gateway, so a new database VM in the private subnet cannot download packages from the public internet. If your instructor requires a live MySQL service for the last test, use an approved database-ready AMI or an approved private package mirror; do not make the DB public just to install packages.

## Finish safely

Once you have captured the logs and observation table, remove the paid AWS resources:

```bash
terraform destroy
```

Type `yes` only after Terraform shows the expected experiment resources. Keep your `.pem` key outside this folder and never commit it.
