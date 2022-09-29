# eks-sandbox-terraform
Quickly spin up an AWS EKS cluster with terraform

# Use
```shell
cd workerspace/sandbox
terraform init
terraform apply -var access_key=<AWS_ACCESS_KEY> -var secret_key=<AWS_ACCESS_SECRET>
```
