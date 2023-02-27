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
  - stage: stage-example
    displayName: Stage example name
    jobs:
      - job: job-example
        displayName: Job example name
        steps:
          - task: NodeTool@0
            displayName: 'Use Node 16.x'
            inputs:
              versionSpec: '16.x'

          - script: |
              yarn --frozen-lockfile
            displayName: 'Yarn install'
```
