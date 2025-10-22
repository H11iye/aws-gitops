import { S3 } from 'aws-sdk';

const s3 = new S3();

export async function processS3Object(bucket: string, key: string) {
  console.log(`Processing object bucket=${bucket}, key=${key}`);
  const obj = await s3.getObject({ Bucket: bucket, Key: key }).promise();
  // parse / transform obj.Body
  const outputBucket = process.env.OUTPUT_BUCKET!;
  await s3.putObject({ Bucket: outputBucket, Key: `processed/${key}`, Body: obj.Body as Buffer }).promise();
  console.log(`Wrote processed object to ${outputBucket}/processed/${key}`);
}
