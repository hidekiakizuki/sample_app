#!/bin/bash
# このファイルに実行権限を与えてください。
# chmod +x docker/localstack/init-aws.sh
awslocal sqs create-queue --queue-name default --region ap-northeast-1
