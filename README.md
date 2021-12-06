# For Rearc-Data

This fork is private to Rearc Data, and is specifically intended to mimic our ADX data provider platform.

To get started, clone this repo and make sure you have docker-compose installed.

## AWS Credentials

Set your AWS credentials in ``docker/aws_credentials`` (a template file is provided for the first time). Get these credentials from [the SSO login page](https://rearc.awsapps.com/start), from "Data Sourcing", from the "Command line or programmatic access" link on the right hand side. These keys rotate daily or more, so you'll need to refresh these credentials daily.

## Syncing DAG's

Your ``rearc-data-provider`` code needs to be available within this repo. You can do this one of two ways

### Manual re-sync

You can use the provided ``sync_code.sh`` script to pull the appropriate folders from the relevant locations. Just update ``root`` at the top, and fire off the script anytime you make a change that you want to test in MWAA.

### Hard link the folders

You can also hard-link the needed folders into the MWAA folder. Specifically, link ``rearc-data-provider/dags <-- mwaa/dags``, ``rearc-data-provider/jobs <-- mwaa/jobs``, and ``rearc-data-provider/rearc_data_utils <-- mwaa/dags/rearc_data_utils`` (this is likely to cause issues in your original repo, so I can probably fix this at some point...).

## Launching

You can now follow the README below as normal to launch your local MWAA instance.

# About aws-mwaa-local-runner

This repository provides a command line interface (CLI) utility that replicates an Amazon Managed Workflows for Apache Airflow (MWAA) environment locally.

## About the CLI

The CLI builds a Docker container image locally that’s similar to a MWAA production image. This allows you to run a local Apache Airflow environment to develop and test DAGs, custom plugins, and dependencies before deploying to MWAA.

## What this repo contains

```text
dags/
  requirements.txt
  tutorial.py
docker/
  .gitignore
  mwaa-local-env
  README.md
  config/
    airflow.cfg
    constraints.txt
    requirements.txt
    webserver_config.py
  script/
    bootstrap.sh
    entrypoint.sh
  docker-compose-dbonly.yml
  docker-compose-local.yml
  docker-compose-sequential.yml
  Dockerfile
```

## Prerequisites

- **macOS**: [Install Docker Desktop](https://docs.docker.com/desktop/).
- **Linux/Ubuntu**: [Install Docker Compose](https://docs.docker.com/compose/install/) and [Install Docker Engine](https://docs.docker.com/engine/install/).
- **Windows**: Windows Subsystem for Linux (WSL) to run the bash based command `mwaa-local-env`. Please follow [Windows Subsystem for Linux Installation (WSL)](https://docs.docker.com/docker-for-windows/wsl/) and [Using Docker in WSL 2](https://code.visualstudio.com/blogs/2020/03/02/docker-in-wsl2), to get started.

## Get started

```bash
git clone https://github.com/aws/aws-mwaa-local-runner.git
cd aws-mwaa-local-runner
```

### Step one: Building the Docker image

Build the Docker container image using the following command:

```bash
./mwaa-local-env build-image
```

**Note**: it takes several minutes to build the Docker image locally.

### Step two: Running Apache Airflow

Run Apache Airflow using one of the following database backends.

#### Local runner

Runs a local Apache Airflow environment that is a close representation of MWAA by configuration.

```bash
./mwaa-local-env start
```

To stop the local environment, Ctrl+C on the terminal and wait till the local runner and the postgres containers are stopped.

### Step three: Accessing the Airflow UI

By default, the `bootstrap.sh` script creates a username and password for your local Airflow environment.

- Username: `admin`
- Password: `test`

#### Airflow UI

- Open the Apache Airlfow UI: <http://localhost:8080/>.

### Step four: Add DAGs and supporting files

The following section describes where to add your DAG code and supporting files. We recommend creating a directory structure similar to your MWAA environment.

#### DAGs

1. Add DAG code to the `dags/` folder.
2. To run the sample code in this repository, see the `tutorial.py` file.

#### Requirements.txt

1. Add Python dependencies to `dags/requirements.txt`.  
2. To test a requirements.txt without running Apache Airflow, use the following script:

```bash
./mwaa-local-env test-requirements
```

Let's say you add `aws-batch==0.6` to your `dags/requirements.txt` file. You should see an output similar to:

```bash
Installing requirements.txt
Collecting aws-batch (from -r /usr/local/airflow/dags/requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/5d/11/3aedc6e150d2df6f3d422d7107ac9eba5b50261cf57ab813bb00d8299a34/aws_batch-0.6.tar.gz
Collecting awscli (from aws-batch->-r /usr/local/airflow/dags/requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/07/4a/d054884c2ef4eb3c237e1f4007d3ece5c46e286e4258288f0116724af009/awscli-1.19.21-py2.py3-none-any.whl (3.6MB)
    100% |████████████████████████████████| 3.6MB 365kB/s 
...
...
...
Installing collected packages: botocore, docutils, pyasn1, rsa, awscli, aws-batch
  Running setup.py install for aws-batch ... done
Successfully installed aws-batch-0.6 awscli-1.19.21 botocore-1.20.21 docutils-0.15.2 pyasn1-0.4.8 rsa-4.7.2
```

#### Custom plugins

- Create a directory at the root of this repository, and change directories into it. This should be at the same level as `dags/` and `docker`. For example:

```bash
mkdir plugins
cd plugins
```

- Create a file for your custom plugin. For example:

```bash
virtual_python_plugin.py
```

- (Optional) Add any Python dependencies to `dags/requirements.txt`.

**Note**: this step assumes you have a DAG that corresponds to the custom plugin. For examples, see [MWAA Code Examples](https://docs.aws.amazon.com/mwaa/latest/userguide/sample-code.html).

## What's next?

- Learn how to upload the requirements.txt file to your Amazon S3 bucket in [Installing Python dependencies](https://docs.aws.amazon.com/mwaa/latest/userguide/working-dags-dependencies.html).
- Learn how to upload the DAG code to the dags folder in your Amazon S3 bucket in [Adding or updating DAGs](https://docs.aws.amazon.com/mwaa/latest/userguide/configuring-dag-folder.html).
- Learn more about how to upload the plugins.zip file to your Amazon S3 bucket in [Installing custom plugins](https://docs.aws.amazon.com/mwaa/latest/userguide/configuring-dag-import-plugins.html).

## FAQs

The following section contains common questions and answers you may encounter when using your Docker container image.

### Can I test execution role permissions using this repository?

- You can setup the local Airflow's boto with the intended execution role to test your DAGs with AWS operators before uploading to your Amazon S3 bucket. To setup aws connection for Airflow locally see [Airflow | AWS Connection](https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/connections/aws.html)
To learn more, see [Amazon MWAA Execution Role](https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-create-role.html).

### How do I add libraries to requirements.txt and test install?

- A `requirements.txt` file is included in the `/dags` folder of your local Docker container image. We recommend adding libraries to this file, and running locally.

### What if a library is not available on PyPi.org?

- If a library is not available in the Python Package Index (PyPi.org), add the `--index-url` flag to the package in your `dags/requirements.txt` file. To learn more, see [Managing Python dependencies in requirements.txt](https://docs.aws.amazon.com/mwaa/latest/userguide/best-practices-dependencies.html).

## Troubleshooting

The following section contains errors you may encounter when using the Docker container image in this repository.

## My environment is not starting - process failed with dag_stats_table already exists

- If you encountered [the following error](https://issues.apache.org/jira/browse/AIRFLOW-3678): `process fails with "dag_stats_table already exists"`, you'll need to reset your database using the following command:

```bash
./mwaa-local-env reset-db
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
