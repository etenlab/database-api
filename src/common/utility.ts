export function createToken(length = 64): string {
  let result = '';
  const characters =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const charactersLength = characters.length;
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function getBearer(req: any): string | undefined {
  const headers = req.req.rawHeaders as Array<string>;
  const Bearer = headers
    .find((value) => value.includes('Bearer'))
    ?.replace('Bearer', '')
    .trim();
  if (Bearer) return Bearer;
  const bearer = headers
    .find((value) => value.includes('bearer'))
    ?.replace('bearer', '')
    .trim();
  if (bearer) return bearer;
}

export function validateEmail(email: string): boolean {
  if (email.includes('@') && email.includes('.')) {
    return true;
  }
  return false;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function justBearerHeader(bearer: string): any {
  return {
    req: {
      rawHeaders: [`Bearer ${bearer}`],
    },
  };
}
