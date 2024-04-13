export const lambdaHandler = async (event) => {
  console.log(event);
  let actions = [];
  try {
    switch (event.InvocationEventType) {
      case "CALL_ANSWERED":
      case "ACTION_SUCCESSFUL":
        actions = [
          {
            Type: "Speak",
            Parameters: {
              Text: "Hello, World!",
              CallId: event.CallDetails.Participants[0].CallId,
            },
          },
          {
            Type: "Pause",
            Parameters: {
              CallId: event.CallDetails.Participants[0].CallId,
              ParticipantTag: "LEG-A",
              DurationInMilliseconds: "3000",
            },
          },
        ];
        break;
      default:
        break;
    }
  } catch (err) {
    console.log(err);
  }
  return {
    SchemaVersion: "1.0",
    Actions: actions,
  };
};
