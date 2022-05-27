import { IParsedForward } from "didcomm"

import { DIDCommParsedForward } from "./types"

export class ParsedForward implements DIDCommParsedForward {
  public as_value(): IParsedForward {
    throw new Error("'ParsedForward.as_value' is not implemented yet")
  }

  // eslint-disable-next-line @typescript-eslint/no-empty-function
  public free(): void {}
}
