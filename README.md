# IAP-Actions
This modules contains code example to connect github actions to a Private GKE cluster accessed via an IAP proxy

# Instructions
Before running the action workflow we first need to create a private GKE cluster, below is the instructions for this:

### Create GCP Project
This only needs to be run if you do not have an existing project. You may need to enable billing on the account after it has been created

```bash
export PROJECT_ID=iap-test-9kx81
gcloud projects create $PROJECT_ID
gcloud config set project $PROJECT_ID
gcloud services enable compute.googleapis.com
gcloud services enable iap.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable container.googleapis.com
```

### Create Service account for terraform
You will need a service account and key in order to run terraform commands, follow the steps to create a service account, download its key and update the `GOOGLE_APPLICATION_CREDENTIALS` env var:

```bash
export SERVICE_ACCOUNT_ID=iap-terraform
gcloud iam service-accounts create $SERVICE_ACCOUNT_ID --display-name="IAP Terraform"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/owner"
gcloud iam service-accounts keys create key.json --iam-account "$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com"
export GOOGLE_APPLICATION_CREDENTIALS=$PWD/key.json
```

### Run terraform
Now that the account has been configured we can run terrafrom to create the cluster:
```bash
terraform init
terraform apply
```

---

### Configure GitHub Actions
First you will need to create a new github secret called `GKE_PROJECT` and set the value as your project id. Next we need to create a service account for github to use, this will have access to GKE and Storage in order to publish images to the GCP Container Registry:

```bash
export SERVICE_ACCOUNT_ID=iap-github
export PROJECT_ID=iap-test-9kx81
gcloud iam service-accounts create $SERVICE_ACCOUNT_ID --display-name="IAP GitHub"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/storage.objectCreator"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/container.admin"
gcloud iam service-accounts keys create github.json --iam-account "$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com"
```

Once this is complete copy the contents of `github.json` to a github new secret called `GKE_SA_KEY`

---

# terraform Files
|File|Description|
|---|---|
|`bastion.tf`|Contains the IAP proxy bastion|
|`gke.tf`|Contains the private GKE cluster configuration|
|`main.tf`|Contains the project and locals|
|`network.tf`|Configures the vpc and subnet|

# Deploy 
```ssh
terraform apply
```

# Connect to bastion
```ssh
gcloud config set project 
gcloud compute ssh --zone=us-central1-c bastion-vm
```

# Run Remote commands
```ssh
gcloud compute ssh --zone=us-central1-c bastion-vm -- 'date'
```
