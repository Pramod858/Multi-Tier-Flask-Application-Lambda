from PIL import Image
import boto3
import json
import os  # Import os to handle file extensions

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Parse the body to get parameters
    body = json.loads(event['body'])
    width = int(body['width'])
    height = int(body['height'])
    source_key = body['source_key']
    source_bucket = body['source_bucket']
    target_bucket = body['target_bucket']

    print('width = ', width)
    print('heights = ', height)
    print('source_key = ', source_key)
    print('source_bucket = ', source_bucket)
    print('target_bucket = ', target_bucket)

    # Download the image from S3
    original_image_path = '/tmp/original_image'
    s3.download_file(source_bucket, source_key, original_image_path)
    print("Image Downloaded.")

    # Extract the file extension to use when saving the resized image
    file_extension = os.path.splitext(source_key)[1]  # e.g., '.jpg', '.png'
    resized_image_path = f'/tmp/resized_image{file_extension}'

    # Resize the image and save it with the correct extension
    with Image.open(original_image_path) as img:
        img = img.resize((width, height))
        img.save(resized_image_path)  # Save with the correct file extension

    # Upload the resized image back to the target S3 bucket
    resized_key = f"resized-{source_key}"
    s3.upload_file(resized_image_path, target_bucket, resized_key)
    print("Resized image uploaded.")

    # JSON response
    response_body = json.dumps({
        'resized_key': resized_key,
        'message': 'Image resized successfully'
    })

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': response_body
    }
