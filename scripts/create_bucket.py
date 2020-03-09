import boto3
import datetime

try: 
    boto3.resource('s3').create_bucket(Bucket="ci-gorilla-test-habib")
    print('bucket created.')
except e:
    print(e, type(e))