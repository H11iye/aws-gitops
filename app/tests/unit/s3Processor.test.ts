import { processS3Object } from "@/lib/s3Processor";

jest.mock('aws-sdk', ()=> ({
    S3: function() {
        return {
            
        }
    }
}))