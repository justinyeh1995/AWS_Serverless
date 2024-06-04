import boto3
from botocore.exceptions import ClientError
from pprint import pprint
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

print('Loading function')
dynamo = boto3.resource('dynamodb')

def preflight_response():
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': json.dumps({'message': 'Preflight request successful'})
    }

def increment_response(count):
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Visitor count incremented.',
            'count': str(count)
        }),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
        }
    }

def get_response(count):
    return {
        'statusCode': 200,
        'body': json.dumps({
            'count': str(count)
        }),
        'headers': {
            'Content-Type': 'application/json',
        }
    }

def invalid_action_response():
    return {
        'statusCode': 400,
        'body': json.dumps("Invalid action. Supported actions: 'increment' or 'get'."),
        'headers': {
            'Content-Type': 'application/json',
        }
    }


def lambda_handler(event, context):
    '''Demonstrates a simple HTTP endpoint using API Gateway. You have full
    access to the request and response payload, including headers and
    status code.

    To scan a DynamoDB table, make a GET request with the TableName as a
    query string parameter. To put, update, or delete an item, make a POST,
    PUT, or DELETE request respectively, passing in the payload to the
    DynamoDB API as a JSON body.
    '''
    print("Received event: " + json.dumps(event, indent=2))

    operation = event['httpMethod']
    
    if operation == 'OPTIONS':
        return preflight_response()
        
    payload = event['queryStringParameters'] if operation == 'GET' else json.loads(event['body'])
    pprint(f"Payload: {payload}")
    
    website_id = payload['websiteId']
    action = payload['action']

    source_ip = event['headers']['X-Forwarded-For'] # "118.150.128.89" 
    print(source_ip)
    
    if action == 'increment':
        count = increment_visitor_count(website_id, source_ip)
        return increment_response(count)
    elif action == 'get':
        count = get_visitor_count(website_id)
        return get_response(count)
    else:
        return invalid_action_response()

def increment_visitor_count(website_id, source_ip):
    table = dynamo.Table('WebsiteVisitorCount')
    
    try:
        response = table.get_item(Key={'WebsiteID': website_id})
    except ClientError as err:
        logger.warning(f"Error getting item: {err}")
        raise
    
    if 'Item' in response:
        item = response['Item']
        visitor_count = item.get('VisitorCount', 1)
        source_ips = item.get('SourceIP', set())
        visit_times = item.get('VisitTimes', {})
    else:
        visitor_count = 1
        source_ips = set()
        visit_times = {}

    if source_ip not in source_ips:
        source_ips.add(source_ip)
        visit_time = datetime.utcnow().isoformat()
        visit_times[source_ip] = visit_time
        try:
            response = table.update_item(
                Key={'WebsiteID': website_id},
                UpdateExpression='ADD VisitorCount :inc SET SourceIP = :ips, VisitTimes = :times',
                ExpressionAttributeValues={':inc': 1, ':ips': source_ips, ':times': visit_times},
                ReturnValues='UPDATED_NEW'
            )
            visitor_count = response['Attributes']['VisitorCount']
        except ClientError as err:
            logger.warning(f"Error updating item: {err}")
            raise

    return visitor_count


def get_visitor_count(website_id):
    table = dynamo.Table('WebsiteVisitorCount')
    try: 
        response = table.get_item(Key={'WebsiteID': website_id})
    except ClientError as err:
        logger.warning(err)
        raise
    
    if 'Item' in response:
        item = response['Item']
        visitor_count = item.get('VisitorCount', 1)
        return visitor_count
    else:
        return 0