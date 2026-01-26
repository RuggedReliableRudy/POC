import sys
import pandas as pd
from io import BytesIO

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions

from pyspark.context import SparkContext

# -----------------------------
# Glue job setup
# -----------------------------
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# -----------------------------
# S3 Excel file details
# -----------------------------
S3_BUCKET = "aws-glue-testing-macon-test"
S3_KEY = "data/customers.xlsx"

# -----------------------------
# Read Excel from S3 using boto3
# -----------------------------
import boto3
s3 = boto3.client("s3")

obj = s3.get_object(Bucket=S3_BUCKET, Key=S3_KEY)
excel_data = obj["Body"].read()

# Read Excel into pandas DataFrame
pdf = pd.read_excel(BytesIO(excel_data), sheet_name=0)

# Convert pandas → Spark DataFrame
df = spark.createDataFrame(pdf)

# Optional: inspect schema
df.printSchema()

# -----------------------------
# RDS connection details
# -----------------------------
jdbc_url = "jdbc:postgresql://glue-postgres.ca364400af7w.us-east-1.rds.amazonaws.com:5432/testdatabase"
db_table = "public.customers"

connection_properties = {
    "user": "test",
    "password": "test@123",
    "driver": "org.postgresql.Driver"
}

# -----------------------------
# Write to RDS
# -----------------------------
df.write \
  .mode("append") \
  .jdbc(
      url=jdbc_url,
      table=db_table,
      properties=connection_properties
  )

job.commit()
