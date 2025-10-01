import json
import boto3
import os

sqs = boto3.client("sqs")
sns = boto3.client("sns")

QUEUE_URL = os.environ['SQS_QUEUE_URL']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    try:
        for record in event['Records']:
            bucket = record['s3']['bucket']['name']
            key = record['s3']['object']['key']
            
            # Simulate file processing
            result = f"Processed file {key} from bucket {bucket}"
            
            # Send result to SQS
            sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=result)
            
            # Send SNS notification
            sns.publish(TopicArn=SNS_TOPIC_ARN, Message=f"File processed: {key}")
        
        return {"statusCode": 200, "body": json.dumps("Success")}
    
    except Exception as e:
        sns.publish(TopicArn=SNS_TOPIC_ARN, Message=f"Error processing file: {str(e)}")
        raise e
