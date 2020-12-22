# IAP-Actions
Connection via IAP proxy using actions

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
