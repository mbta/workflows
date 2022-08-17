# Reusable workflows

This repository collects our [reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows).

## deploy-ecs.yml

Example usage, in **my_app/.github/workflows/deploy-ecs.yml**:

```yml
name: Deploy to ECS

on:
  workflow_dispatch:
    inputs:
      environment:
        type: environment
        required: true
        default: dev
  push:
    branches: master

jobs:
  call-workflow:
    uses: mbta/workflows/.github/workflows/deploy-ecs.yml@main
    with:
      app-name: my-app
      environment: ${{ github.event.inputs.environment || 'dev' }}
    secrets:
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      docker-repo: ${{ secrets.DOCKER_REPO }}
      slack-webhook: ${{ secrets.SLACK_WEBHOOK }}
```

## deploy-on-prem.yml

Example usage, in **myapp/.github/workflows/dev.yml**

``` yml
name: Deploy to Dev (on-prem)
on:
  workflow_dispatch:
  push:
    branches: [main]

jobs:
  Build:
    runs-on: windows-2019
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
      - uses: mbta/actions/build-push-ecr@v1
        id: build-push
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          docker-repo: ${{ secrets.DOCKER_REPO }}
  Deploy:
    needs: Build
    uses: mbta/workflows/.github/workflows/deploy-on-prem.yml@main
    with:
      app-name: my-app
      environment: dev
      on-prem-cluster: hsctd-dev-managers
      splunk-index: my-app-dev
      task-cpu: 0.25
      task-memory: 256M
      task-port: 8081
    secrets:
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_ACCESS_KEY_ID }}
      docker-repo: ${{ secrets.DOCKER_REPO }}
      splunk-host: ${{ secrets.SPLUNK_HOST }}
      splunk-token-arn: ${{ secrets.SPLUNK_TOKEN_ARN }}
```

