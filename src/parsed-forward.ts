import { DIDCommParsedForward, IParsedForward } from "./types"

export class ParsedForward implements DIDCommParsedForward {
    public as_value(): IParsedForward {
        throw new Error("'ParsedForward.as_value' is not implemented yet")
    }

    public free(): void {
    }
}