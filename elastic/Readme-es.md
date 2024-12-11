# Install Elastic Search on OpenShift

This Ansible project is configured to run inside a **Dev Container** using **Visual Studio Code**. Below is a step-by-step guide to set up and run the project in a controlled and isolated environment.

This project is built using **Ansible**, **Watsonx Code Assistant**, and **Visual Studio Code**. Below are the instructions to set up and run this project using these tools.

## Tools Used:
- <img src="https://docs.ansible.com/ansible/latest/_static/images/Ansible-Mark-RGB_White.png" width="40" /> **Ansible**: Automation tool used to manage configurations, deploy applications, and orchestrate tasks.
- <img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fibm.gallerycdn.vsassets.io%2Fextensions%2Fibm%2Fwatsonx-data%2F0.0.4%2F1714022743268%2FMicrosoft.VisualStudio.Services.Icons.Default&f=1&nofb=1&ipt=29bfe28fe77a672d9618f584400b807b36fcfc7815d1e5d21e583e8b924528c6&ipo=images" width="40" /> **Watsonx Code Assistant**: AI-powered code assistant that helps with generating, refactoring, and managing code.
- <img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstatic-00.iconduck.com%2Fassets.00%2Ffile-type-vscode-icon-512x508-376y62ux.png&f=1&nofb=1&ipt=9e84e86170d65b81be99c3fb36342dab6809bed5d51fbe22d67a3a5f949586d4&ipo=images" width="40" /> **Visual Studio Code**: A powerful, open-source code editor with built-in support for debugging, task running, and version control.




## Requirements

- **Visual Studio Code** (VS Code)
- **Docker** installed and running
- **Dev Containers Extension** for Visual Studio Code
- **Ansible** (preconfigured in the container)

## Steps to Set Up the Environment

### 1. Clone the Repository

Clone the project repository to your local machine:

```bash
git git@github.com:jmorenor86/scaffolding-infra.git
cd scaffolding-infra
```

### 2. Open the Project in Visual Studio Code
Open the project in Visual Studio Code from the project root directory. You can do this directly from the terminal by running:

```bash
code .
```

### 3. Open the Project in a Dev Container
When you open the project in VS Code, ensure that the Dev Containers extension is installed. If it isn't, you can install it by searching for "Dev Containers" in the VS Code Extensions marketplace.

VS Code will automatically detect that the project contains a .devcontainer/devcontainer.json file and ask if you want to reopen the project inside a development container. Click on Reopen in Container.

If the prompt doesn't appear, you can open the container manually by following these steps:

Click on the Dev Containers icon in the left sidebar of VS Code.
Select Reopen in Container.

### 4. Build and Configure the Dev Container
VS Code will use the configuration in the .devcontainer/devcontainer.json file and build the container if necessary. This container will include Ansible and all the dependencies required to run the project.

#  Pre-Configuration (IMPORTANT!!!)

## Prerequisites

1. **Ansible**: Ensure Ansible is installed on your system.
2. **Docker**: Docker must be installed to run containers (if applicable).
3. **Visual Studio Code (VSCode)**: Optional but recommended for an easy development experience.
4. **Access to OpenShift Cluster**: Ensure that you have the necessary credentials to access your OpenShift cluster.


## Step 1: Create the `configuration.json` File

Inside the `elastic/vars` folder, create a file named `configuration.json` with the following content:

```json
{
    "ocp": {
        "version": "",
        "host": "",
        "username": "",
        "password": ""
    },
    "es": {
        "es_namespace": "",
        "es_storageclass": "",
        "es_storage": "",
        "es_cluster": "",
        "es_version": "",
        "es_nodes": "",
        "es_container_name": "",
        "es_container_request_memory": "",
        "es_container_request_cpu": "",
        "es_container_limit_memory": "",
        "es_container_limit_cpu": ""
    }
}

```
## Step 2: Fill in the values for the OpenShift (ocp) and Elasticsearch (es) sections:

ocp: Provide the OpenShift details.

- version: The OpenShift version you are using.
- host: The OpenShift cluster host URL.
- username: Your OpenShift username.
- password: Your OpenShift password.

es: Provide the Elasticsearch details.

- es_namespace: The namespace for Elasticsearch.
- es_storageclass: The storage class for Elasticsearch.
- es_storage: The storage size for Elasticsearch.
- es_cluster: The Elasticsearch cluster name.
- es_version: The Elasticsearch version.
- es_nodes: The number of nodes for the Elasticsearch cluster.
- es_container_name: The name of the Elasticsearch container.
- es_container_request_memory: Memory requested for the container.
- es_container_request_cpu: CPU requested for the container.
- es_container_limit_memory: Memory limit for the container.
- es_container_limit_cpu: CPU limit for the container.

## Step 3: Copy the License File to the `elastic/license/` Folder:

### Instructions:
1. Obtain the `license.json` file from the appropriate source.
2. Place the `license.json` file inside the `elastic/license/` folder.

## Step 4: Execute the execute.sh Script:
After configuring the configuration.json file, navigate to the elastic/ directory and execute the execute.sh script. This script will apply the necessary configurations and deploy the resources.

Run the script by executing the following command in the terminal:

```bash
sh execute.sh
```

Make sure that you have the required permissions and environment to execute the script. This will apply the configurations based on the details you entered in configuration.json.

## Step 5: Execute the execute.sh Script:

After executing the script, validate that the connection data is correct. To do this, check the contents of the /tmp/output_content.txt file. You can view the file with the following command:

```bash
cat /tmp/output_content.txt
```

# Contributing
If you encounter any issues or have suggestions for improvements, feel free to fork the repository and submit a pull request.