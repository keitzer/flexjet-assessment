# ADR-0002: Protocol-based networking and separate DTOs

Status: Accepted (records the existing implementation).

[Documentation index](../README.md) · [Architecture map](../architecture.md)

## Context

The service has two endpoints and returns records with nullable, malformed, and contradictory fields.

## Decision

Use URLSession behind `FlightsAPIClient`, with no third-party app dependencies. Keep wire DTOs
separate from domain and presentation models. `FlightsResponseDTO` decodes records individually;
`Flight.init?(dto:)` validates usable domain data. Drop invalid records while retaining valid
siblings. Reject malformed JSON and non-array top-level responses.

## Consequences

Tests and previews use service doubles. Partial bad data does not hide every flight, but invalid
records are omitted rather than surfaced individually to the user. Preserve independent airport
labels and IATA codes. See [service behavior](../service-and-behavior.md) for fallbacks and examples.
