import { NextRequest, NextResponse } from "next/server";
import { processS3Object } from '@/lib/s3Processor';

export async function POST(request: NextRequest) {
    try {
        const body = await request.json();
        const { bucket, key } = body;
        await processS3Object(bucket, key);
        return NextResponse.json({ status: 'ok'});
    } catch (error) {
        console.error('Error processing S3 object', error);
        return NextResponse.json({ status: 'error', message: (error as Error).message}, { status: 500 });
    }
}