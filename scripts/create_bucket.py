import os
import boto3
import datetime

bucket_name = 'ci-gorilla-test-habib'

# Create bucket
boto3.resource('s3').create_bucket(Bucket=bucket_name)

try: 
    # Create key pair
    key_pair = boto3.resource('ec2').create_key_pair(KeyName=os.getenv('KEY_NAME'))

    # Store in key pair S3 bucket
    key_name = '{}.pem'.format(os.getEnv('KEY_NAME'))

    s3 = boto3.client('s3')
    s3.put_object(Body=key_pair.key_material, Bucket=bucket_name, Key=key_name)

    with open(key_name, "w") as fh:
        fh.write(key_pair.key_material)
        
    os.chmod(key_name, 0664)

except Exception as e:
    pass

print("Success")