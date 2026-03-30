# Checkpoint 04 - Tenant Profile Schema

## Status

Proposed normalization spec.

This document defines the canonical tenant profile schema used to personalize the golden workspace preset for a fresh tenant deploy.

It is intentionally based on the current intake form you provided.

## Objective

Turn raw intake answers into one machine-readable tenant profile that drives:

- workspace personalization
- initial dashboard state
- workflow readiness emphasis
- auth handoff expectations

The goal is to stop doing freeform rewrites during onboarding.

## Scope

This schema is for:

- fresh tenant deploys
- the first personalized workspace state
- consistent downstream use by Ava/operator automation

This schema is not for:

- existing tenant upgrades
- incident repair
- live migration overrides

Those should be treated as separate migration or operations flows, not as onboarding profile questions.

## Hard Assumptions For Now

- deployment mode is always `fresh`
- timezone defaults to `America/Los_Angeles`
- there is no separate preferred assistant name field for now
- onboarding should use the intake as the authoritative raw input

## Why This Checkpoint Matters

Right now the intake exists, but there is no single normalized profile that future automation can rely on.

Without this checkpoint:

- onboarding stays ad hoc
- workspace personalization stays fuzzy
- dashboard state risks drifting from intake truth
- future agents keep inventing mappings instead of following one contract

## Source Intake Dimensions

The current intake already captures the right kinds of information:

- operator type
- business structure
- territory
- services sold
- weekly workload shape
- quote volume
- repeated monthly tasks
- first action on new opportunity
- stall points
- delay causes
- portal/vendor complexity
- systems in use
- mandatory systems
- first accounts to prepare
- browser-portal reliance
- file storage
- note habits
- folder organization
- quote emphasis
- paperwork behavior
- commission tracking
- approval boundaries
- immediate value outcome
- contact + legal consent

This is enough to normalize a first-pass tenant profile.

## Canonical Tenant Profile Schema

The normalized profile should contain the following top-level sections.

## 1. Profile identity

Purpose:

- identify the tenant and operator at onboarding time

Fields:

- `schemaVersion`
- `deploymentMode`
- `timezone`
- `contact.fullName`
- `contact.businessName`
- `contact.email`
- `contact.phone`
- `contact.legalConsent`

Rules:

- `deploymentMode` is fixed to `fresh`
- `timezone` defaults to `America/Los_Angeles` unless the product later adds a real timezone field

## 2. Operator classification

Purpose:

- determine the operator archetype and business shape

Fields:

- `operatorType`
- `businessStructure`
- `territory`

Examples:

- Sandler agent
- Sandler sub-agent
- Agent with sub-agents
- Agency owner / sales leader
- Newer agent building my workflow

## 3. Sales and workload profile

Purpose:

- determine the real workflow emphasis

Fields:

- `serviceMix`
- `biggestWeeklyWorkload`
- `activeOpportunityRange`
- `weeklyQuoteVolume`
- `monthlyRepeatingTasks`
- `newOpportunityFirstAction`
- `stallPoints`
- `quoteDelayCauses`
- `multiVendorComplexity`

This section should drive:

- workflow emphasis
- skills highlighted first
- initial workflow readiness defaults

## 4. Systems and portal profile

Purpose:

- define the systems the tenant actually lives in

Fields:

- `systemsInUse`
- `mandatorySystems`
- `accountsToPrepareFirst`
- `browserPortalReliance`
- `fileStorage`
- `noteHabits`
- `folderOrganization`

This section should drive:

- `TOOLS.md`
- initial `business.json`
- initial `workflows.json`
- auth handoff checklist

## 5. Quote, paperwork, and commission profile

Purpose:

- define the practical workflow pressure points

Fields:

- `quotePriority`
- `paperworkBehavior`
- `commissionTracking`

This section should influence:

- follow-up and quote workflow emphasis
- task suggestions
- ready/not-ready workflow summaries

## 6. Approval and value profile

Purpose:

- define what the assistant must gate
- define what "immediate usefulness" means for this tenant

Fields:

- `approvalBoundaries`
- `immediateValueGoal`

This section should drive:

- `AGENTS.md` personalization overlays if needed
- `MEMORY.md`
- initial dashboard business and workflow framing

## Mapping Rules

## Rule 1 - Intake answers stay raw

Store the raw intake values in the tenant profile.

Do not prematurely rewrite them into agent prose.

The profile is the machine-readable input layer.

## Rule 2 - Workspace docs are projections of the profile

The following files should be generated or personalized from the tenant profile:

- `USER.md`
- `TOOLS.md`
- `MEMORY.md`
- initial `state/business.json`
- initial `state/workflows.json`

## Rule 3 - The tenant profile is not the long-term memory file

The tenant profile captures onboarding truth.

Later learning belongs in:

- `MEMORY.md`
- dashboard state
- operational notes

Do not treat the profile as the day-to-day mutable business memory.

## Rule 4 - Existing-tenant upgrades are out of scope

This schema should not ask:

- "is this an upgrade?"
- "is this an existing tenant?"
- "should we preserve current deploy?"

That logic belongs to migration and operations tooling.

It should not contaminate the clean onboarding path.

## Recommended Canonical Shape

The profile should use a shape like this:

- `schemaVersion`
- `deploymentMode`
- `timezone`
- `contact`
- `classification`
- `salesProfile`
- `systemsProfile`
- `operationsProfile`
- `approvalProfile`

This keeps the schema compact and explicit.

## Example Default Choices From Current Constraints

For now, these defaults should be baked in:

- `deploymentMode = "fresh"`
- `timezone = "America/Los_Angeles"`

The system should not wait on a timezone answer before moving forward.

## How This Schema Feeds The Workspace

### `USER.md`

Primary inputs:

- contact name
- business name
- territory
- operator type
- service mix
- biggest weekly workload
- immediate value goal

### `TOOLS.md`

Primary inputs:

- systems in use
- mandatory systems
- accounts to prepare first
- browser portal reliance
- file storage

### `MEMORY.md`

Primary inputs:

- business structure
- friction points
- delay causes
- approval boundaries
- note habits
- folder organization

### `state/business.json`

Primary inputs:

- business and operator identity
- mandatory systems
- approved portals
- channel/storage/system facts

### `state/workflows.json`

Primary inputs:

- quote workload
- portal reliance
- systems in use
- accounts to prepare first
- paperwork behavior
- commission tracking behavior

## What The Schema Should Not Try To Solve

This schema should not yet try to encode:

- every future workflow preference
- every auth token
- exact portal credential values
- existing-tenant migration state
- dynamic task state

Those belong elsewhere.

## Exit Criteria For Checkpoint 4

Checkpoint 4 is complete only when:

1. There is one canonical tenant profile schema.
2. The schema is explicitly derived from the intake you already have.
3. Fresh deploy is the only onboarding mode in this schema.
4. Timezone has a default and does not block onboarding.
5. There is a clear mapping from profile fields to workspace personalization outputs.
6. Future agents can say "fill profile, then personalize known files" instead of improvising onboarding.

## Immediate Implementation Direction

After this spec is accepted, the next work should be:

- align or replace the current `workspace/tenant-profile.template.json`
- produce a canonical example profile from your current intake
- define the personalization step that reads this profile and updates the exact workspace files

## Relationship To Later Checkpoints

This checkpoint does not yet define:

- the exact end-to-end provisioning flow
- the final smoke test and ready-check contract

Those come next.
