import {
  CreateSipMediaApplicationCallCommand,
  ChimeSDKVoiceClient,
} from "@aws-sdk/client-chime-sdk-voice";

const chimeClient = new ChimeSDKVoiceClient({ region: process.env.REGION });

export const lambdaHandler = async (event: any) => {
  console.log(event);
  try {
    const reqeustBody = JSON.parse(event.body);
    const sipMediaApplicationId = process.env
      .SIP_MEDIA_APPLICATION_ID as string;
    const fromPhoneNumber = reqeustBody.fromPhoneNumber;
    const toPhoneNumber = reqeustBody.toPhoneNumber;

    const callDetails = await chimeClient.send(
      new CreateSipMediaApplicationCallCommand({
        SipMediaApplicationId: sipMediaApplicationId,
        FromPhoneNumber: fromPhoneNumber,
        ToPhoneNumber: toPhoneNumber,
      })
    );
    return response(200, {
      message: "Call Initiated Successfully",
      transactionId: callDetails.SipMediaApplicationCall?.TransactionId,
    });
  } catch (err) {
    console.log(err);
    return response(400, {
      message: "Failed to make call",
      error: err,
    });
  }
};

function response(statusCode: number, body: any) {
  return {
    statusCode: statusCode,
    body: JSON.stringify(body),
  };
}
