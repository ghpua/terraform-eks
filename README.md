# Terraform EKS Cluster
See credits for source/base works

__NOTE__: deploying an EKS cluster will incur cost for AWS resources.

## Prerequisites
- AWS Account where you have Root or IAM user with AdministratorAccess policy or equivalent
- AWS Cloud9 client
  - Login to the AWS account
    - If using the Root account:
      - Create an IAM user (Access types: Programmatic & Console access; attach AdministratorAccess policy)
      - Log out of the Root account, then back in with the user just created
  - Choose Cloud9 from the AWS Console list of services
  - Choose a region geographically close to you that supports Cloud9 (Region selector is top left of Console)
  - Choose to create an environment
  - Provide an Environment Name of your choice
  - Leave the Environment description blank, click Next Step
  - On the next page accept all default settings - click Next Step
  - On the Review page, note the recommendations and warnings, click Next Step
  - Wait for your Cloud9 environment to be provisioned
- Once the environment starts, in the terminal proceed with the next steps
- In the Cloud9 Preferences (cog symbol in top right) preferences --> aws settings --> disable AWS managed temp creds
- From the terminal window `aws configure` and supply the access key and secret key for your IAM user
- Move terraform wrapper so it can be invoked from any folder

  `chmod +x ./terraform && sudo mv ./terraform /usr/local/bin`
  
- Download Heptio Authenticator

  `curl -o heptio-authenticator-aws https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/heptio-authenticator-aws`

- Install Heptio Authenticator

  `chmod +x heptio-authenticator-aws && sudo mv heptio-authenticator-aws /usr/local/bin/`

- Install kubectl

  `curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.10.3/bin/linux/amd64/kubectl`
  
  `chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl`


## Quickstart
#### Deploy
- Clone this repo

 `git clone <repo-url>`
 
- List existing terraform workspaces

 `terraform workspace list`
 
- Create a terraform workspace for the environment you wish to create

 `terraform workspace new <environment>_<aws-region>`
 
 - Eg
 
 `terraform workspace new development_us-west-2`

 `terraform workspace new production_us-east-1`

- Bring up the environment and put kubectl settings in place. This takes ~15min

 `./eks cluster up`

- Load kubectl configuration into your shell env

 `export KUBECONFIG=~/.kube/eksconfig`
 
- Deploy the json-server pod

 `kubectl apply -f json-server.yaml`

- Check if the json-server pod is running
 `kubectl get pods --all-namespaces`

- Locate the service URL for json-server

 `kubectl get svc -o wide`

- Copy the json-server EXTERNAL-IP from previous step and launch via port 8000
  - URL may look like `http://a2ec4e6b66a2411e883240aa8289a10c-778396272.us-west-2.elb.amazonaws.com:8000/`


#### Switch cluster / terraform workspace

- Switch to a pre-existing terraform workspace (for an environment you already created)
 
 `terraform workspace select <environment>_<aws-region>`

 `./eks cluster up`

 `export KUBECONFIG=~/.kube/eksconfig`


#### Validate

- Check the cluster is deployed correctly

 `terraform workspace select <environment>_<aws-region>`

 `./eks cluster up`

 `export KUBECONFIG=~/.kube/eksconfig`

 `./eks run health`

#### Change worker node settings on an existing cluster, eg instance size

- Ensure we are targetting the intended cluster

 `terraform workspace list`

 `terraform workspace select <environment>_<aws-region>`
 
- Taint the necessary resources

 `terraform taint -module=worker aws_autoscaling_group.eks_workers`
 
 `terraform taint -module=worker aws_launch_configuration.eks_workers`
 
- Apply changes

 `./eks cluster up`

 `export KUBECONFIG=~/.kube/eksconfig`


#### Destroy an existing cluster

- Ensure we are targetting the intended cluster

 `terraform workspace list`

 `terraform workspace select <environment>_<aws-region>`

 `./eks cluster up`

 `export KUBECONFIG=~/.kube/eksconfig`

- Delete all deployed pods, eg json-server

NOTE: (failing to complete this step may orphan resources and block the terraform destroy)

 `kubectl delete -f json-server.yaml`

- This next step takes ~15min

 `terraform destroy`

## Credits
- [yamaszone](https://github.com/yamaszone/terraform-eks) for PoC EKS solution
- [Segmentio Stack](https://github.com/segmentio/stack) for VPC related modules
- [WillJCJ](https://github.com/WillJCJ/eks-terraform-demo) for EKS related modules


"expose k8s asg settings at top level vars; modify az selection;"
