import json
import boto3
def lambda_handler(event, context):
    print("In lambda handler")
    print(event)
    http_body= event["body"]
    get_file_content = event['body']
    dynamodb = boto3.client('dynamodb')
    dynamodb.put_item(TableName='pedidosDB', Item=json.loads(http_body))
    # 'idOrder': {'N': '33333'}, 'product': {'S': 'aromaticas'},'quantity': {'N': '2'},'status': {'S': 'pending'}
   
    resp = {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
        },
        "body": "credibanco-test!"
    }
    
    return resp