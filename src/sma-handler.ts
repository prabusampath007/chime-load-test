export const lambdaHandler = async (event) => {
  console.log(event);
  return {
    SchemaVersion: "1.0",
    Actions: [],
  };
};
