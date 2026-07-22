import boto3
from botocore.exceptions import ClientError

BUCKET_NAME = "project-atlas-fmallari"

s3 = boto3.client("s3")


def upload_file(file_obj, object_key):
    """
    Upload a file-like object to Amazon S3.

    Args:
        file_obj: File object from Flask request.files
        object_key: Path/name to store in S3

    Returns:
        True if upload succeeds, False otherwise.
    """
    try:
        s3.upload_fileobj(file_obj, BUCKET_NAME, object_key)
        return True

    except ClientError as e:
        print(f"S3 Upload Error: {e}")
        return False
