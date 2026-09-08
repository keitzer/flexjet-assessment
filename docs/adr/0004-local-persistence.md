# ADR-0004: Keychain sessions and device-local preferences

Status: Accepted (records the existing implementation).

[Documentation index](../README.md) · [Architecture map](../architecture.md)

## Context

Tokens must survive relaunch, while the service provides no completion endpoint. Haptics and
appearance are device preferences.

## Decision

Store bearer tokens in Keychain. An authenticated 401 expires only the current session. Store
completed flight IDs and Profile preferences in UserDefaults. Share `FlightCompletionStore` so
detail actions update list checkmarks without another fetch. Completion and undo are available
only after departure. Haptics defaults on; appearance defaults to System. Preferences survive sign-out.

## Consequences

Completion is device-local and is not synchronized to the service. No write endpoint is invented.
The root view applies appearance, and all app-generated haptics consult one preference gate.
See [service behavior](../service-and-behavior.md#completion) and [UI notes](../ui-notes.md).
