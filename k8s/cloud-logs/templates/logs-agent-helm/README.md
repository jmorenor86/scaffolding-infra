# helm-charts

helm charts for installing logs-agent. The same helm-charts can be used to install on IKS and Openshift clusters

## Before you begin

- [Install helm ( helm )](https://helm.sh/docs/intro/install/)
- [Install the IBMCloud CLI ( ibmcloud )](https://cloud.ibm.com/docs/cli?topic=cli-getting-started)
- [Install the Kubernetes CLI ( kubectl )](https://kubernetes.io/docs/tasks/tools/)
- [Install the Openshift CLI ( oc )](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift-cli)

## Logs agent install

Each versioned chart uses a corresponding agent version which is defined in values.yaml file which is not advised to change.

### Create the logs-values.yaml file for logs-agent install

Create a file named "logs-values.yaml" with the content below and fill the required fields. Already filled fields can be updated based on your needs.

```yaml
metadata:
  name: "logs-agent"
image:
  version: "1.3.0"  # required

clusterName: "" # recommended to improve the metadata

env:
  # ingestionHost is a required field. For example:
  # ingestionHost: "<logs instance>.ingress.us-east.logs.cloud.ibm.com"
  ingestionHost: "" # required

  # If you are using CSE proxy, then use port number "3443"
  # If you are using private VPE Gateway, then use port number "443"
  # If you are using the public endpoint, then use port number "443"
  ingestionPort: "" # required

  iamMode: "TrustedProfile"
  # trustedProfileID - trusted profile id - required for iam trusted profile mode
  trustedProfileID: "" # required if iamMode is TrustedProfile

scc:
  # true here enables creation of Security Context Constraints in Openshift
  create: true
```

See the [Configuration Options](#configuration-options) section below for other configurations.

### Installation steps

- Login to ibmcloud

```sh
ibmcloud login -a cloud.ibm.com --sso
```

- Get the cluster list

```sh
ibmcloud oc clusters
```

- Configure the cluster for agent deployment

```sh
ibmcloud oc cluster config -c <CLUSTER_NAME> --admin
```

Install the helm chart from the icr.io repository

```sh
helm install <install-name> --dry-run oci://icr.io/ibm/observe/logs-agent-helm --version <version> -f ./logs-values.yaml -n ibm-observe --create-namespace
```

If you are using `iamMode` as `iamAPIKey` then you can pass the key as a parameter:

```sh
helm install <install-name> --dry-run oci://icr.io/ibm/observe/logs-agent-helm --version <version> -f ./logs-values.yaml -n ibm-observe --create-namespace --set secret.iamAPIKey=<your iamAPIKey>
```

After inspecting the dry-run output you can run the install by removing the --dry-run

```sh
helm install <install-name> oci://icr.io/ibm/observe/logs-agent-helm --version <version> -f ./logs-values.yaml -n ibm-observe --create-namespace
```

You can mange your installation by other helm commands including `helm upgrade`, `helm uninstall` and `helm help`

All image versions do not work with all versioned charts. The version in the Chart.yaml is the number appears in the versioned charts (the .tgz files). Please follow the table below when selecting the image version for a versioned chart.

----

## Configuration Options

The following values may be provided in order to change the default settings.

| Parameter | Description | Default |
|-----------|-------------|---------|
| metadata.name | The name used for all of the Kubernetes resources | required - no default |
| image.version | The version of the agent container image (ie. 1.3.0) | required - no default |
| env.ingestionHost | The Cloud Logs host to send the logs to | required - no default |
| env.ingestionPort | The Cloud Logs port to send the logs to | required - no default |
| env.iamMode | Indicate the IAM authentication mechanism used - `TrustedProfile` or `IAMAPIKey` | required - no default |
| env.trustedProfileID | The Trusted profile to use - required when iamMode=TrustedProfile | optional |
| env.iamEnvironment | Controls the IAM endpoint used by the agent to exchange the tokens | Production |
| env.iamHost | IAM host required for IAM Environment `Custom` setting.  See [below](#enviamenvironment) | required for iamEnvironment `Custom` - no default |
| secret.iamAPIKey | The APIKey used when iamMode=IAMAPIKey - only should be provided via the CLI - see below | optional |
| clusterName | The name of the kubernetes cluster | optional |
| scc.create | When to create the Secure Context Constraints in Openshift | false |
| defaultMetadata.subsystemName | static string to override the subsystemName in Cloud Logs | container that generated the log |
| defaultMetadata.applicationName | static string to override the applicationName in Cloud Logs | namespace name that generated the log |
| resources | Override the kubernetes resources allocated to the logs-agent | See below |
| additionalLogSourcePaths | The path of additional logs beyond the default /var/log/containers/*.log | optional - not set |
| excludeLogSourcePaths | Additional logs that should not be collected by the agent | optional - not set |
| selectedLogSourcePaths | Override /var/log/containers/*.log and only collect logs in these paths | optional - not set |
| includeAnnotations | Instruct the kubernetes plugin to include the container annotations with the log messages | false |
| retryLimit | Limit the number of retries that will be attempted | False - no retry limits |
| loggingLevel | The type of logs that should be reported by the agent itself (debug,info,error) | info |
| additionalMetadata | A list of key/value pair tags that can be added as metadata to every log line | optional - not set |
| keepParsedLogs | If a log is parsed by the Kubernetes filter, still keep the original `log` field containing the message | false |
| outputWorkers | The number of worker threads used by the output plugin to send to Cloud Logs | 4 |
| severityFieldName | The name of the field to be used to populate the severity field in the log record when a severity field doesn't already exist | optional - not set |

## Configuration Option Details

### env.iamMode

This option allows you to choose to leverage an IAM APIKey instead of the default Trusted Profile configuration.

If `env.iamMode: "TrustedProfile"` is set, then the `env.trustedProfileID` variable must also be provided.

If `env.iamMode: "IAMAPIKey"` is set, then the configuration expects a secret to be defined that contains an IAM Apikey with permissions.
If the `secret.iamAPIKey` variable is provided on the helm command (ie. `--set secret.iamAPIKey=<your iamAPIKey>`), then the helm chart will create the Kubernetes secret.

Alternatively, you can create the secret ahead of time with the command:

```sh
kubectl create secret generic <helm install-name> -n ibm-observe --from-literal=IAM_API_KEY=<apikey>
```

```yaml
env:
  iamMode: IAMAPIKey
```

### defaultMetadata

This section allows the user to override the default subsystemName and applicationName that are used in the environment.
By default, the values are not set and the output plugin will dynamically set the values to:

- applicationName: the Kubernetes namespace that generated the log
- subsystemName: the container name that generated the log


```yaml
defaultMetadata:
  subsystemName: ""
  applicationName: ""
```

### resources

This section allows the user to change the resources that are assigned to the agent container.  By default, the values
shown below are used.  If you need to update any of the values, the entire configuration must be provided even if you
don't update all of the values.

```yaml
resources:
  limits:
    cpu: 500m
    ephemeral_storage: 10Gi
    memory: 3Gi
  requests:
    cpu: 100m
    ephemeral_storage: 2Gi
    memory: 1Gi
```

### Log Source Paths configurations

The following additional variables can be provided to include, exclude or restrict the set of logs to be processed.

By default the agent will collect the logs from `/var/log/containers/*.log`.

- `additionalLogSourcePaths` adds locations to the default set of logs that will be processed.
- `excludeLogSourcePaths` ignores logs in the specified locations
- `selectedLogSourcePaths` overrides the default and ignores the additionalLogSourcePaths configurations

```yaml
# comma separated list, for example “/var/log/abc/*.log,/var/log/xyz/*.log”
additionalLogSourcePaths: ""
excludeLogSourcePaths: ""
selectedLogSourcePaths: ""
```

### env.iamEnvironment

This configuration controls the IAM endpoint used by the agent to exchange the tokens.  The default value of `Production` will be appropriate for most customers.

Valid values are :

- `Production` : `iam.cloud.ibm.com` (default)
- `ProductionPrivate` : `private.iam.cloud.ibm.com`
- `Custom` : `<user provided - see below>`


```yaml
env:
  iamEnvironment: "Production"
```

_Note_: For `Custom` iamEnvironment setting, the user must provide the following value:
- `env.iamHost` (ex. `private.eu-de.iam.cloud.ibm.com`)
```yaml
env:
  iamEnvironment: "Custom"
  iamHost: "private.eu-de.iam.cloud.ibm.com"
```

### includeAnnotations

This configuration changes the setting for the Kubernetes filter to include the annotations from Kubernetes with the log records.  The default value for this setting is `false`.

```yaml
includeAnnotations: true
```

### retryLimit

This configuration places a limit on the number of times the agent will retry sending if an error occurs that is considered to be retryable.  The default is False.  See the [Fluentbit documentation about retries](https://docs.fluentbit.io/manual/administration/scheduling-and-retries) to understand the implications of setting this value.  In some situations this setting could lead to log data being discarded by the agent due to the inability to send.

```yaml
retryLimit: 8
```

### additionalMetadata

This is a list of key/value pairs that will be added under the `meta` object to permit additional tags

```yaml
additionalMetadata:
  region: ca-tor
  env: production
```

The above example will result in the following additional fields added to each log line in Cloud Logs:

```json
{
  "meta": {
    "region": "ca-tor",
    "env": "production"
  }
}
```

### keepParsedLogs

This is a boolean that indicates whether we should keep the original `log` field that was successfully processed by the kubernetes plugin.  If you choose to enable this, there will be duplication of data in the log record which requires additional storage.  The default value is false.

```yaml
keepParsedLogs: true
```

### outputWorkers

This is the number of worker threads defined in the output plugin in order to have parallel processing of data within the environment.  By default 4 workers are used and in most situations, having more worker threads should not impact the performance of your environment.  If your log volumes are such that you need to allocate more than 1 CPU to keep up with the outgoing volume, then increasing this value to 8 (along with the CPU increase) will increase the output throughput.  Reducing this value to 1 or 2 will decrease the maximum log volume that can be sent to Cloud Logs.

```yaml
outputWorkers: 2
```

### severityFieldName

This is an optional field that can be provided to override the severity field passed to Cloud Logs.  This is useful if your logs have a non-standard field name ( ie. Log_Level ) for identifying the severity of the log message.  This setting will introduce a new filter that injects a field named `severity` into your log line and populates it from the field name provided.

```yaml
severityFieldName: Log_Level
```
