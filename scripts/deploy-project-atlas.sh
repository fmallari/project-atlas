#!/usr/bin/env bash

set -euo pipefail

AWS_REGION="us-east-2"
AWS_ACCOUNT_ID="764553891483"
ECR_REPOSITORY="project-atlas"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
CONTAINER_NAME="project-atlas-container"
SERVICE_NAME="project-atlas-container"
IMAGE_TAG="${1:-}"

if [[ -z "$IMAGE_TAG" ]]; then
  echo "Usage: $0 <image-tag>"
  exit 1
fi

NEW_IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

CURRENT_IMAGE="$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME" 2>/dev/null || true)"

deploy_image() {

  local image="$1"

  systemctl stop "$SERVICE_NAME" || true

  docker rm "$CONTAINER_NAME" 2>/dev/null || true

  docker create --name "$CONTAINER_NAME" -p 127.0.0.1:8080:8000 "$image"

  systemctl start "$SERVICE_NAME"

}

validate_deployment() {
  echo "==> Waiting for application startup"
  sleep 5

  echo "==> Checking application health"
  curl --fail --silent --show-error http://127.0.0.1:8080/health >/dev/null

  echo "==> Checking critical static asset"
  curl --fail --silent --show-error --head http://127.0.0.1:8080/static/css/portfolio.css >/dev/null
}

rollback() {

  if [[ -z "$CURRENT_IMAGE" ]]; then

    echo "ERROR: No previous image available for rollback"

    exit 1

  fi

  echo "==> Deployment failed"

  echo "==> Rolling back to: $CURRENT_IMAGE"

  deploy_image "$CURRENT_IMAGE"

  if validate_deployment; then

    echo "==> Rollback successful"

    echo "Restored image: $CURRENT_IMAGE"

  else

    echo "CRITICAL: Rollback validation failed"

    exit 1

  fi

  exit 1

}

echo "==> Authenticating to Amazon ECR"

aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "==> Pulling candidate image"

docker pull "$NEW_IMAGE"

echo "==> Deploying candidate image"

if ! deploy_image "$NEW_IMAGE"; then
   echo "==> Candidate deployment failed"
  rollback
fi

if ! validate_deployment; then
  rollback
fi

echo "==> Deployment successful"


