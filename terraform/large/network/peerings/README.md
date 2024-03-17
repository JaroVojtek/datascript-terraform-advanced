# Step 4: Peerings

In this section you will setup peering between VPCs.

## Edit Terraform files

- In `locals.tf` and `provider.tf` replace `ref` value/prefix by acronym of your company. You can navigate to the directory and use following shell command to do so

  ```bash
  sed -i 's/ref/<your acronym>/' locals.tf provider.tf
  ```

- In `peering.tf` configure the peering. The default peering is between VPC in `shared` account and remaining accounts.

## Commands to execute this stage

```bash

cd network/peerings

terraform init

terraform providers lock \
  -platform=windows_amd64 \
  -platform=darwin_amd64 \
  -platform=linux_amd64

terraform plan

terraform apply
```

**Continue with optional [Step 5: Routes](/network/routes/README.md)**
