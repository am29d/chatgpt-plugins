---
name: room-planning
description: Model and furnish apartments and multi-floor houses through chat or voice, including dimension edits and editable furniture reconstructed from uploaded photos, using Spielraum's 2D/3D planner.
---

# Model a home with Spielraum

## Sign-in

Open `spielraum.panel` when sign-in is required. Let the user use **Sign in** and
complete Clerk login in their browser. `spielraum.get_auth` checks status;
`spielraum.sign_in` starts the device flow only when requested. Show its verification
URL and public user code. Never request passwords, identity/refresh tokens or the
private device code in chat. `spielraum.sign_out` signs out this device when asked,
preserving homes. Every home tool is gated even when called without opening the UI.
Each verified account has a separate local profile; never claim an old anonymous
home for the first person who logs in or import it without an explicit ownership
choice and backup.

Read `spielraum.get_workspace` before creating or editing. A saved home survives
restarts and is shared by the sidebar and conversation. When first showing a
home, call `spielraum.panel` once after creation, only if no planner is already
open. Reuse that pane on follow-up turns. Never reopen it after `set_floor` or
repeat `panel` just to refresh: open views receive workspace updates.
Keep the conversation visible; fullscreen is an explicit user choice. The result
contains `building` (or null), its ID/revision and the complete plan for every floor.
It also contains `history`: persistent workspaceId/revision, undo/redo counts and
next-action labels, including while the home is empty.

Use `spielraum.create_apartment` for a single floor or
`spielraum.create_building` for named levels, such as Keller, EG, OG and DG.
Up to eight floors are supported, each with its own dimensions and layout.
An identical retry is safe; a different creation never overwrites an open home.
Use `spielraum.set_floor` to revise or add one floor afterwards. Pass the current
building ID and `expectedRevision`; include the complete floor plan to retain.
Omitted collections become empty. Other floors stay unchanged. On conflict,
read the latest plan and reapply the user's intended change.

Furniture is separate and always preserved by set_floor. Preserve each room's
stable id on rename. Structural edits that invalidate furniture are rejected;
move or reassign affected items before retrying.

## Furniture through chat and voice

Use get_furniture to inspect items and dimensions. Resolve “it”, “the cabinet
below the TV” or “the other chair” using conversation, selected itemId, names,
floor, room and positions. Query is a literal substring filter; inspect the room
inventory for relational descriptions. Clarify multiple matches. Users need not
click anything: show true can focus an item/room/floor; mode plan/model selects
2D/3D without a canvas action.

apply_furniture_changes accepts atomic add, update, model-patch, duplicate and remove batches.
Rooms start locked. Before adding or editing, include a room-lock operation with
floorId, roomId and locked false for each affected room. Moves require both source
and destination unlocked. These choices are saved and shared with the manual UI.
Respect a user's instruction to keep a room protected. Use locked true to finish
editing when requested. A locked piece also needs its own unlock update.
Use stable IDs, current buildingId/expectedRevision and a fresh operationId.
Reuse the exact ID and arguments for retries. Omit unaffected update fields.
Explicit dimensions default to measured; mark guesses estimated and explain
omitted dimensions use defaults. Announce success only after a successful result
and report actual saved dimensions. Width is local X, depth Z, height Y; rotation
is degrees, x/z is the floor-space center and baseY is mounting elevation.

Families: sofa, corner-sofa, armchair, chair, table, round-table, desk, bed,
wardrobe, cabinet, shelf, lamp, rug and custom. Without a detailed model these use
editable approximations. For detailed descriptions, product references and photo
reconstruction, add a generic ThreeJSON model as described below. Do not claim an
exact product mesh or illumination simulation for a lamp.

Choose floorId/roomId from get_workspace; null is valid only for a floor without
named rooms. Omit x/z together for automatic placement. A room/floor update
without coordinates proposes a new placement. Resize anchor west/east/north/south
preserves that world-space edge. Locked items require a separate unlock update.
Report returned door, physical-intersection and uncertain-fit warnings.
Use related item IDs and part names to offer a concrete correction. Clear modeled
parts do not prove real-world clearance when measurements or geometry are estimated.

Voice uses the same tools as chat; the app does not need its own microphone.
Convert English/German cm/m, decimal commas and explicit feet/inches to meters.
“Make it 240 wide” inherits the established unit; clarify if none is established.
Read current values for relative changes. Use the final value in “ninety-five,
actually ninety”. Clarify uncertain transcription or left/right reference frames
before editing. Support spoken review, cancellation and undo. Host voice
availability/transcription and image interpretation require separate real tests.

Use `spielraum.undo` / `spielraum.redo` for the latest/next shared workspace edit.
Read history first and describe its action label when another view/chat may have
edited. Pass history.workspaceId and history.revision as expectedRevision, plus a
new operationId reused exactly on retries. The last 50 logical edits include
structure, furniture, detailed models, locks and photo drafts and survive restart.
Undo creation restores empty; redo restores the same IDs. A new successful edit
clears redo. Workspace restoration may reverse locked-room edits. Migration starts
history at the existing home; earlier full edits are unavailable. Typed/voice
requests use these same tools. Camera and selection do not create history steps.

The compatible undo_furniture_change reverses targetOperationId with a new operationId/current
revision. It preserves unrelated edits, but refuses to overwrite an affected
item changed afterwards or change locked rooms. Its latest 100 furniture request
records survive restart; it is separate from workspace history. Creation and
set_floor accept optional operationId for durable exact retries. Use a fresh ID
when deliberately recreating an identical undone home. Receipts return current
state plus the original operationRevision; never treat an old retry as a new edit.

## Uploaded furniture photos

Visually inventory the actual attachments first: visible objects, count, shape,
color/material and placement relationships. Preserve visible furnishings and
details. Do not add imagined pieces or invent brands, hidden geometry or exact
scale. Product photos need destinations; room photos need room identity and
useful scale references. Prefer the user's assignment; otherwise compare known
openings/layout and clarify ambiguous rooms. Never change structure to fit a photo.

prepare_furniture_import stages YOUR interpretation; the server does not analyze
pixels itself. Supply current building/revision, a new importId, and candidates.
Pass attachments through images file params or imageIds. Identify each object's
sources using item.sources with imageId/observationId, or observations with
imageIndex/observationId. Indices address imageIds first, then attached images.
Combine multiple observations of one object into one candidate. Use targetId for
the same existing object across new views; do not merge merely similar chairs.

Photo dimensions default to estimated, omitted values to default. Mark measured
only when supplied by the user or clearly readable as a dimension label. Ask for
width/depth/height where fit matters; one scale reference cannot resolve every
occluded dimension. Use roomId null when unresolved; that candidate stays blocked.
Omit x/z for automatic placement or encode supported relationships as estimated
coordinates/rotation.

Summarize objects, assigned rooms, estimates and uncertainties. Valid candidates
appear translucently; accepted furniture is unchanged. Use resolve_furniture_import
revise with the complete corrected candidate list for spoken corrections. Apply
when the user accepts, after resolving blocked rooms/geometry. An entire import
is one undoable operation. Preserve sources on corrections. Reimports preserve
user measurements and specified positions automatically.

## Materials and colors

Set `finishes.floor` to `{ material: "oak" | "tile" | "concrete", color?: "#RRGGBB" }`
and `finishes.walls` to `{ material: "paint" | "concrete", color?: "#RRGGBB" }`.
Interior walls can set `finish` to override the floor's wall finish. Defaults
are oak and warm-white paint; plain concrete defaults to gray. Preserve these
fields on later edits. Tile/concrete are simple finishes, without scanned
textures or a product catalog. Oak uses the existing texture; its color is a tint.

## Describe geometry

All coordinates are meters from each floor's northwest clear interior corner:
x increases east, z increases south. Convert other units before calling tools.
`width` and `depth` are clear interior dimensions (1–30 m). Defaults are 2.5 m
ceiling height, 0.2 m exterior walls, 0.12 m interior walls, 2.05 m door height
and 1.2 m window height. Declare assumptions; do not call them measured.

- Without `outline`, four exterior walls are generated. Add openings through
  `exteriorOpenings` keyed north/south/east/west.
- For L/U/stepped apartments, supply `outline`: ordered `{x,z,openings?:[...]}`
  clear-interior corners. Close implicitly; never repeat the first vertex. Either
  winding is accepted. Edges must be axis-aligned, nonzero, nonintersecting and
  turn at every vertex (merge collinear edges). Width/depth are the complete
  bounding box, spanning x=0..width and z=0..depth; the origin can be outside the
  apartment at a cutout. Each vertex owns the boundary edge to the NEXT vertex.
  Put exterior openings on that vertex, using absolute ascending x coordinates
  for horizontal edges or z for vertical edges, regardless of winding. Leave
  `exteriorOpenings` empty. Walls and flooring follow the outline automatically.
  Preserve `outline` and all edge openings on edits; omission restores a rectangle.
- Mark only the apartment entrance from communal/outside space with `entry:true`
  on its exterior door. Balcony/loggia doors are not entrances.
- `walls` contains interior walls in the existing PlanWall format. `axis: x`
  runs east/west at z=`at`; `axis: z` runs north/south at x=`at`.
- Wall openings use the existing door/window/sliding contracts. Sort by start;
  keep spans non-overlapping and inside the wall, and below the ceiling.
  Door `hinge` is start/end; `side` is -1/+1 along the perpendicular coordinate.
  Windows need a sill height and can specify height/divisions.
- `rooms` defines rectangular focus/label areas (`west/east/north/south`).
  Room bounds do not generate walls: supply physical partitions separately.
  Unverified room bounds default to `basis: Image estimate`.
- `stairs` defines straight flights with bounds, rise, steps and direction.
  Rise includes the floor slab; ask for stair location and floor-to-floor height.
  The receiving floor needs an explicit rectangular `floorOpenings` entry.
  Each level is viewed separately; this is not a stacked whole-building view.

Use the supplied plans and description. Ask for missing dimensions/positions.
Create the known parts progressively instead of rejecting a whole home because
some details remain unknown. Do not infer a complete plan from floor names.
Do not silently substitute the original reference apartment or house.

Floor switching, 2D/3D, room focus, orbit/pan/zoom, walls and measurements stay
local in the UI. Shadows remain off. No model tool is needed for view controls.
The Furniture menu selects a piece for the OpenAI UI inspector. Users can unlock
its room, edit dimensions and appearance, drag in 2D/3D, duplicate, remove and
undo. Enter or blur saves a numeric field; Escape cancels it. Manual edits use the
same saved furniture, validation and revisions as chat. Read current values again
after a user edits them directly.

The viewer reuses PropertyFloor/PlanWall, shared masonry/opening/stair builders,
PlannerScene, PlayCanvas, PlanDrawing and existing view controls. Current creation
supports rectangular and orthogonal polygon footprints with axis-aligned walls. Diagonal or curved boundaries,
sloped roofs, curved/spiral stairs and image-generation tools
are not exposed yet. A DG can be a named floor; do not claim a sloped roof.

The active home is stored locally and shared by MCP processes. Tests and
previews can use `SPIELRAUM_DATA_DIR` for an isolated workspace. Existing saved
layouts/galleries are never read or overwritten. Spielraum makes no AI API calls itself.

## Reconstruct a floor plan from an image

First distinguish the apartment's boundary from communal stairs/landings,
neighboring homes, fixtures, dimension lines and door-swing arcs. Trace the full
clear-interior outline before partitions. Never fill its bounding rectangle when
there are cutouts. A loggia needs its actual separating wall/opening; decide from
the source whether it belongs inside the modeled outline. Common stairs outside
this apartment are not an internal stair flight.

Read printed dimension chains and distinguish overall dimensions from dimensions
of one wing. Establish one coordinate frame and scale; verify independent chains
agree. Do not invent survey precision from pixels. Keep image-derived offsets
estimated; say which dimensions/defaults are assumed. Do not model counters,
wardrobes, sanitary fixtures or swing arcs as structural walls.

Place physical partitions and actual doors/windows separately from room label
areas. A room label creates no enclosure or access. For an irregular room, use a
contained rectangular label/focus area; never let it bridge a cutout. Mark the
actual entrance door, then call `inspect_floor_plan`. Repair unreachable rooms by
checking the SOURCE for missing/misplaced openings or walls, not inventing doors.
Missing entrance or analysis-limit results leave access unverified. Run inspection
again after structural corrections. It checks connectivity, not image fidelity,
minimum passage widths or building regulations. Compare the saved 2D boundary,
partitions and openings to the source before calling the reconstruction complete;
review 3D afterwards and disclose any remaining uncertainty.

## Detailed furniture of any kind

Add/update `model: { format: "threejson", descriptor: { ... } }` on an item.
Use kind `custom` for arbitrary objects; the model owns visible geometry.
A root descriptor has `threeJsonId` and `objType`. Groups use `subScene`, not
`children`. Every part needs a stable unique ID; prefer meaningful names.
Use local meters, X width, Y up, Z depth, and radians for descriptor rotations.
The item's floor position/rotation remain separate; item rotation uses degrees.

General geometry: box, cylinder, sphere, cone, plane, torus, bufferMesh,
editableMesh with topology/Catmull-Clark modifiers, sweepMesh and latheMesh.
Groups nest these; `holes` subtracts cutter descriptors. Curved stems use a
profile/path; hollow shades use lathe profiles with inside and outside points.
Use separate observed feet, cushions, arms and trim. For flat cushions with soft
edges, include support loops before subdivision; subdividing an eight-vertex cube
makes it excessively round. No category-specific tools or executable code are needed.

Materials support color, roughness, metalness, transparency, color/normal/roughness
maps. Use #RRGGBB and packaged paths: `/materials/linen-{color,normal,roughness}.webp`
and `/materials/oak-{color,normal,roughness}.webp`. NormalScale `{x:0.12,y:0.12}`
gives restrained cloth relief. Set textureRepeat and UV projection for scale.
No external URLs, lights, events, shaders or downloaded models are accepted.
get_furniture_model returns all permitted material paths.

Syntax fragment (add all actual supports/details):
`{"threeJsonId":"piece","objType":"group","subScene":[{"threeJsonId":"top",
"objType":"box","geometry":{"width":1.2,"height":0.05,"depth":0.6},
"position":{"x":0,"y":0.72,"z":0},"material":{"type":"standard",
"color":"#b5966f","roughness":0.8}}]}`.

Read get_furniture_model itemId before editing; partId reads one part.
model-patch takes item id, partId and JSON Patch operations relative to that part,
e.g. `[{op:"replace",path:"/geometry/width",value:1.4}]`. Use add for absent fields.
Preserve IDs and unrelated parts. Changed bounds update overall size with the
previous source-to-world scale. Anchors preserve a cardinal world-space edge.
Read sourceSize and current dimensions when converting distances after scaling.
For “wider, feet unchanged”, edit the affected source shape/positions; scalar item
width scales the feet too. Item color tints all parts; model-patch edits one part's
material. The UI's whole-piece material action updates every part. Model null
restores the family approximation. Existing room locks, revisions, retries and undo apply.

Keep descriptors compact: max 64 parts, 128 KB, 100k generated vertices/triangles,
and subdivision at most level 3. Home-level budgets also apply. On a budget error,
reduce detail. Label image-derived dimensions estimated and explain inferred details.
