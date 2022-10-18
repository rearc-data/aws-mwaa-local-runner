docker buildx build --pull --platform linux/amd64,linux/arm64 --cache-from=registry --push -t 658443672529.dkr.ecr.us-east-1.amazonaws.com/amazon/mwaa-local:2.2.2 -f docker/Dockerfile docker
