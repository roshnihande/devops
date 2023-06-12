version: 0.2
variables:
  snowflake_package: ': snowflake-connector-python==3.0.3' 
phases:
  pre_build:
    commands:
      - echo rbac handler codebuild pipeline ...
  build:
    commands:
      - echo "creating zip file"
      - pip3 install --target . -r requirements/requirements.txt
      - zip -r rbac.zip .
      - echo "creating zip file for Lambda layer"
      - mkdir -p snowflake/python
      - cd snowflake/python
      - pip3 install --platform manylinux2014_x86_64 --target=. --implementation cp --python 3.9 --only-binary=:all$SNOWFLAKE_PACKAGE
      - cd ..
      - zip -r provisioning-lambda-layer.zip python
      - cd ..

  post_build:
    commands:
      - echo "uploading Lambda layer"
      - aws s3api put-object --bucket $S3_Bucket --key provisioning-lambda-layer.zip --body snowflake/provisioning-lambda-layer.zip
      - aws lambda publish-layer-version --layer-name provisioning-lambda-layer --compatible-runtimes python3.9 --content S3Bucket=$S3_Bucket,S3Key=provisioning-lambda-layer.zip --region us-east-1
      - export LATEST_LAYER_VERSION=$(aws lambda list-layer-versions --layer-name provisioning-lambda-layer --query 'LayerVersions[0].Version')
      - echo "latest layer version $LATEST_LAYER_VERSION"
      - echo deploying lambda functions ...
      - aws s3api put-object --bucket $S3_Bucket --key rbac.zip --body rbac.zip
      - aws lambda update-function-code --function-name $publisher_lambda --s3-bucket $S3_Bucket --s3-key rbac.zip
      - aws lambda update-function-code --function-name $reprovisioning_lambda --s3-bucket $S3_Bucket --s3-key rbac.zip
      - aws lambda update-function-code --function-name $hourly_lambda --s3-bucket $S3_Bucket --s3-key rbac.zip
      - aws lambda update-function-code --function-name $provisioning_dlq_redrive_lambda --s3-bucket $S3_Bucket --s3-key rbac.zip
      - aws lambda update-function-configuration --function-name $provisioning_lambda --layers "arn:aws:lambda:$REGION:$ACCOUNT_ID:layer:provisioning-lambda-layer:$LATEST_LAYER_VERSION"

artifacts:
  files:
    - '**/*'
