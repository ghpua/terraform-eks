# Terraform EKS Cluster
See credits for source/base works

__NOTE__: deploying an EKS cluster will incur cost for AWS resources.

## Prerequisites
- AWS Account where you have Root or IAM user with AdministratorAccess policy or equivalent
- AWS Cloud9 client
  - Login to the AWS account
  -- If using the Root account:
  --- Create an IAM user (Access types: Programmatic & Console access; attach AdministratorAccess policy)
  --- Log out of the Root account, then back in with the user just created
  - Choose Cloud9 from the AWS Console list of services
  - Choose a region geographically close to you that supports Cloud9 (Region selector is top left of Console)
  - Choose to create an environment
  - Provide an Environment Name of your choice
  - Leave the Environment description blank, click Next Step
  - On the next page accept all default settings - click Next Step
  - On the Review page, note the recommendations and warnings, click Next Step
  - Wait for your Cloud9 environment to be provisioned
- Once the environment starts, in the terminal proceed with the next steps
- Move terraform wrapper so it can be invoked from any folder
  `chmod +x ./terraform && sudo mv ./terraform /usr/local/bin`
- Download Heptio Authenticator
  `curl -o heptio-authenticator-aws https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/heptio-authenticator-aws` 
- Install Heptio Authenticator
  `chmod +x heptio-authenticator-aws && sudo mv heptio-authenticator-aws /usr/local/bin/`
- Install `kubectl`
  `curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.10.3/bin/linux/amd64/kubectl`
  `chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl`

## Quickstart
#### Deploy
- git clone <repo-url> this repo
- `./eks cluster up` # Takes ~15min
- `kubectl apply -f nginx.yaml` # Deploy an example Nginx pod
- `export KUBECONFIG=~/.kube/eksconfig`
- `kubectl get pods` # Check if the Nginx pod is running
- `kubectl get svc -o wide` # Locate the service URL for Nginx
- Copy the Nginx URL from previous step and launch the Nginx welcome page via port 8000
  - URL may look like `http://a2ec4e6b66a2411e883240aa8289a10c-778396272.us-west-2.elb.amazonaws.com:8000/`
#### Destroy
- `kubectl delete -f nginx.yaml` # Delete Nginx pod if deployed based on the sample
- `terraform destroy` # Takes ~15min

## Credits
- [yamaszone](https://github.com/yamaszone/terraform-eks) for PoC EKS solution
- [Segmentio Stack](https://github.com/segmentio/stack) for VPC related modules
- [WillJCJ](https://github.com/WillJCJ/eks-terraform-demo) for EKS related modules

