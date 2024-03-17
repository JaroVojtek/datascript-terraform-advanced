# Grafana

## Datasources
Datasources are provisioned in [`datasources.tf`](datasources.tf) file.

> **Note**
>
> We are relying on the datasource UID to be well-defined, and it is generated from the key of the input variable `datasources`.

### CloudWatch
CloudWatch datasource and related IAM role and policy are provisioned in [`cloudwatch.tf`](cloudwatch.tf) file. We are creating a datasource for each Grafana instance and environment. For example, `module.cloudwatch-shared-ec1-prod-ec1` datasource is created for `shared-ec1` Grafana instance and `prod-ec1` environment, so the `shared-ec1` Grafana instance can query CloudWatch metrics from `prod-ec1` environment.

## Folders
Folders are provisioned in [`folders.tf`](folders.tf) file. The key in the map `folders` is the folder path representing [`dashboards`](dashboards) or [`alerts`](alerts) folder structure and the value being the folder name.

> **Note**
>
> We are relying on the folder UID to be well-defined, and it is generated from the folder path. For example, `services/service-mesh` folder UID is `services-service-mesh`.

## Dashboards
Dashboards are provisioned in [`dashboards.tf`](dashboards.tf) file. The provisioning finds all `*.json` files in the [`dashboards`](dashboards) directory and creates a dashboard from each file.

> **Note**
>
> We are relying on the dashboard UID to be well-defined, and should be in a format of `replace("<filename>.json", "_","-")`. For example, `k8s_container.json` dashboard UID should be `k8s-container`.

## Alerting
Alerting is provisioned in [`alerting.tf`](alerting.tf) file.

### Alert rules
We distinguish between user-defined and service alert rules. User-defined alert rules are defined in [`alerts`](alerts) directory and service-defined alert rules are defined in a service directory i.e. [`terraform-aws-memcached`](../../../modules/terraform-aws-memcached/grafana/alerts).

#### User-defined alert rules
The provisioning finds all `*.json` files in the [`alerts`](alerts) directories and creates alert rule from each file in the corresponding folder given by the JSON file path and group given by `ruleGroup` JSON attribute.

You can start by defining the alert rule via Grafana UI and then fetch alert rule definition.

> **Note**
>
> As of now, Grafana does not support exporting the alert group JSON model from the UI. Run a helper script [`get-alert-group.sh`](scripts/get-alert-rule.sh) to fetch the alert group JSON model from Grafana API and place it in the [`alerts`](alerts) directory.

#### Service alert rules
When adding Grafana alert rule for a service, you can start by defining alert rule the same way as user-defined alert rule. Then, you can place the alert rule JSON file inside the service directory i.e. [`terraform-aws-memcached`](../../../modules/terraform-aws-memcached/grafana/alerts) and tweak it as needed. For an example you can add a variable within JSON file to have the alert rule work for multiple environments, pass the JSON file to `templatefile` function and use the result as the rule with [`terraform-aws-eks-grafana-rule-groups`](../../../modules/terraform-aws-eks-grafana-rule-groups) module, see [`alerting.tf`](../../../modules/terraform-aws-memcached/alerting.tf) for an example.

### Contact points
Contact points provisioning uses environment variables to fill in secrets (not working at the moment due to <https://github.com/grafana/grafana/issues/54984> which is closed, but not fixed in the Terraform context). Environment variables are set using `external-secrets` and pulled from Secret Manager secret given by `grafana_secret_manager_name` variable of the Grafana module `modules/terraform-aws-eks-grafana` into Grafana environment variables using `envFromSecret`.

> **Note**
>
> Do not forget to enable Secret Manager integration by setting `grafana_secret_manager_enabled` variable to `true` in the `modules/terraform-aws-eks-grafana` module.

The following environment variables are used for the provisioning and the same keys must be created in the Secret Manager secret:

#### Slack
- `GF_CONTACT_POINT_SLACK_TOKEN` - Slack App oAuth token

#### Google Chat
- `GF_CONTACT_POINT_GOOGLE_CHAT_URL` - Google Chat Webhook URL

#### Teams
- `GF_CONTACT_POINT_TEAMS_URL` - Microsoft Teams Webhook URL

#### Email
To enable Email Contact Point functionality using AWS SES SMTP relay please follow steps bellow:
  1. Provision AWS SES resources by executing terraform in /env/<environment_name>/services/ses/ in environment where Grafana runs (default: shared-ec1 )
  2. After AWS SES is configured, it is recommended to create AWS Support Case in other to take AWS SES account from "AWS SES Sandbox" environment. This provides you with posibility to send email notifications also to unverified email addresses. You can follow this AWS documentation link with detailed steps and explanations: [Moving out of the Amazon SES sandbox](https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html)

**_NOTE:_** Required IAM User credentials for email sending via SMTP are autmatically stored in secret manager within `ses/smtp_user` secret name. Those are then injected in Grafana pod as environmental variables (GF_SMTP_USER, GF_SMTP_PASSWORD) utilizing external-secrets addon.

  3. Enable Grafana SMTP email and provide neccessary configuration parameters (e.g.) in `grafana.tf`

```
  grafana_smtp_email_enabled      = true                                     #required
  grafana_smtp_email_host         = "email-smtp.eu-central-1.amazonaws.com"  #optional
  grafana_smtp_email_port         = 587                                      #optional
  grafana_smtp_email_from_address = "no-reply@acme.org"                      #required
  grafana_smtp_email_from_name    = "Grafana"                                #optional
```
**_IMPORTANT_**: You are able to use already working SES which is configured in different region or AWS account. All you need to do is to manually store SMTP IAM user credentials in secrets manager under secret name `ses/smtp_user`. The required `key:value` schema for secret content is:
```
username: <IAM_user_access_key_id>
password: <IAM_user_secret_access_key>
```

4. Once email server is configured, you can define email contact point configuration parameters within alerting.tf terraform file

```
contact_points = {
  "<name>" = {
    email = {
      addresses = [<email-11@acme.org>, <email-2@acme.org<>] #required
      subject   = ""                                         #optional
      message   = ""                                         #optional
      settings  = {}                                         #optional
    }
  }
}
```

## OIDC
OIDC authentication is managed in [`grafana.tf`](grafana.tf). Secrets Manager can be used to store OIDC credentials. Set `grafana_secret_manager_enabled = true`, create a secret called `grafana`(or a different name via `grafana_secrets_manager_name`), and store the sensitive OIDC credentials in [environment-variable format](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#override-configuration-with-environment-variables). Configure your OIDC provider/providers via `grafana_auth`.

## Installation
Run
```
terraform init
terraform apply
```
