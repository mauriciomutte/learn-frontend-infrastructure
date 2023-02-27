# Azure Pipelines: CI/CD using YML with templates

## Understanding Azure Pipelines

![image](https://user-images.githubusercontent.com/20569339/221383196-a54c0748-9dbd-455b-b782-9d74a3122463.png)

### 1. What is Azure Pipelines?

- Azure Pipelines is continuous integration and delivery (CI/CD)
- Enables teams to continuously build, test, and deploy applications
- It is part of the Azure DevOps Services suite of tools

### 2. What pain does it solve?

#### CI/CD

- Improve software quality by detecting errors and bugs early on.
- Reduce repetitive manual work, freeing up developers to focus on more important tasks.

#### Templates

- **Reuse and consistency:** Using YAML pipeline templates enables defining reusable building blocks that can be used across multiple pipelines, improving consistency and reducing duplication.
- **Simplify pipeline creation:** Allows developers to use existing standardized templates for new pipeline creation.
- **Collaboration:** Storing pipelines on Github makes any changes visible and allows for more efficient collaboration with others.

### 3. Pipeline structure

![image](https://user-images.githubusercontent.com/20569339/221383115-f75c0984-a636-4302-99eb-c7c48c752e54.png)

- **Pipeline:** A pipeline is a set of interconnected steps that define how your code is built, tested, and deployed. It includes everything from checking out code from a repository to deploying the final product.

- **Stages:** A stage is a logical grouping of jobs that represent a phase in your pipeline. For example, you might have a build stage that compiles your code and a test stage that runs automated tests.

- **Jobs:** A job is a set of steps that runs on an agent. Each stage can have one or more jobs, and each job can run in parallel with other jobs in the same stage.

- **Steps:** A step is a single action that can be performed in a job. For example, you might have a step that runs a unit test, or a step that deploys your code to a staging environment. Steps can be run in sequence or in parallel, depending on your pipeline configuration.

See the code example:

```yaml
stages:
  - stage: stage-name
    displayName: Stage display name
    jobs:
      - job: job-name
        displayName: Job display name
        steps:
          - task: NodeTool@0
            displayName: 'Use Node 16.x'
            inputs:
              versionSpec: '16.x'

          - script: |
              yarn --frozen-lockfile
            displayName: 'Yarn install'
```

### 4. Templates

Templates are reusable, shareable, and parameterized pipeline definitions that can be used to define a pipeline, stages, jobs, etc. Templates make it easy to define pipelines that can be used across multiple projects, without having to rewrite the same code over and over again.

Let's say you have different "jobs" with some common steps like installing node and installing dependencies. We could have a template for that and use it in these jobs (which are also templates)

```yaml
# templates/yarn-install.yml

parameters:
  - name: nodeVersion
    type: string
    default: '14.x'

steps:
  - task: NodeTool@0
    displayName: 'Use Node ${{ parameters.nodeVersion }}'
    inputs:
      versionSpec: ${{ parameters.nodeVersion }}

  - script: |
      yarn --frozen-lockfile
    displayName: 'Yarn install'
```

```yaml
# my-pipeline.yml

jobs:
  job: job-name
  steps:
    - template: ./templates/yarn-install.yml
      parameters:
        nodeVersion: '16.x'
```

### 5. Using template in a project

To reuse a pipeline you've created to be used as a template in other Azure Pipelines projects, you can “import” it as a resource and extend it in your project's `azure-pipelines.yml` file.

**Note:** first need to grant Azure DevOps access to your pipeline template repository. If you're using GitHub, you can manage this by navigating to _Settings > Integrations > Applications_ and configuring _Azure Pipelines app_.

```yaml
resources:
  repositories:
    - repository: templates
      type: github
      name: <your-github-username>/<template-repository>
      endpoint: github.com
      ref: main

extends:
  template: <template-repository>/<pipeline-file>.yaml@templates
```
