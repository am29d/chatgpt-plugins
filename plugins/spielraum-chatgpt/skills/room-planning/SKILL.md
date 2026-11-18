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
For existing structure, read `spielraum.inspect_spatial_floor`: physical spaces,
semantic zones, wall assemblies, stable side surfaces, junctions and openings
have distinct identities. Use `spielraum.preview_spatial_floor`, then
`spielraum.edit_spatial_floor` with the same saved revision and command batch.
Unlock affected zones first and request `topologyPolicy: repartition` explicitly
when a change splits or merges spaces. Respect fixed zones; follow-space zones
can track their enclosing wall. Unsupported connected edits require a consistent
`replace-floor` command, never guessed disconnections. A batch is one undoable
edit; `itemChanges` can explicitly rehost, detach, remove or place affected items
in that same transaction. Preview does not save anything. Reuse operationId and
exact arguments on uncertain retries; reread/replan after a revision conflict.

`spielraum.set_floor` remains an import/full-replacement shorthand for adding
floors or faithfully representable simple plans. Supply the complete legacy
floor fields to retain; omitted collections become empty. It rejects rich
spatial references it cannot preserve. Never remove spatial/attachment data to
work around that rejection. Other floors stay unchanged.

Furniture is separate and always preserved by set_floor. Preserve each room's
stable id on rename. Structural edits that invalidate furniture are rejected;
move or reassign affected items before retrying.

To place a picture, shelf or other bounded item on a wall, create the item, then
use `spielraum.set_surface_attachment` with the stable surface ID and local
u/v center coordinates in metres. Choose start/end/proportional anchoring
deliberately. Mounted world position and orientation follow the surface; use
the attachment tool to reanchor or detach, rather than patching x/z/elevation.
Validate complete extents and openings. Spatial fit does not establish mounting
hardware, load capacity or real-world wall construction. Roof slopes and
diagonal/curved wall geometry remain unsupported; record the missing evidence.

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

For a furnishing proposal, identify the occupants, intended uses and required
pieces, stating practical assumptions. Reserve entrances and circulation first;
place large furniture, then related groups such as chairs at tables and storage
with usable fronts. Prefer omitting optional pieces to blocking essential use.
For an intended dining set, default to tucking about 70% of each chair's depth
under the tabletop in the stored position, facing the table with its back
outside the tabletop edge. Use explicit positions for the group. Adjust the
spacing along the edge or tuck less if the chair would hit a leg, apron or
tabletop. Check pullout and seated clearance separately, and follow the user's
placement preference when specified.
For a whole home, room redesign or critique, follow [Furnish and review a
home](design-review.md): plan each room's functions, compare arrangements at
bottlenecks, verify use in context, and compare clearances before and after.
Treat a request for ideas, a review or “what if” as read-only. For a redesign or
a tight placement, pass the proposed furniture batch as `candidate` to
`inspect_furnished_layout` before applying it. Use the same saved revision and
route width for the current layout and each alternative. A candidate result
describes a simulation. Apply only the chosen batch if the user asked for an
edit, then inspect the new saved revision. If it changed in the meantime, read
again and compare against the new state.
For a narrow edit, preserve every unaffected item, dimension, position, floor
and opening. Broad requests such as “make the apartment feel bigger” authorize
designing with the existing shell. Confirm before moving walls or openings,
removing existing pieces, or changing locked furniture to make a proposal fit.
Reserve the operating space for each required use before filling the room.
Keep confirmed blockers, missed planning targets, and unverified conditions
separate. Apply the linked room-specific benchmarks to the relevant scenario.
Review spare floor and wall space for unmet uses. Compare usable worktop,
reachable storage or other task space gained after reserving circulation and
operating clearances. Give remaining open space a purpose.
Default to zero modeled gap behind beds, kitchen cabinets, wardrobes, bookcases
and other wall-backed furniture. Choose a solid wall before placing a bed and
put the headboard against it. Leave usable approaches at the foot and on both
sides of a double bed where possible, and at least one side of a single bed.
Keep the center of the room available for circulation or a group that needs
access around it, such as a dining set. Calculate center coordinates from the
physical wall face and the rotated furniture bounds. If a door, window, fitting
or required clearance makes that wall unsuitable, try another wall first.
Preserve deliberate clearances and user-specified positions. Verify the actual
rear edge yourself for explicit coordinates and custom models. Check for a
solid wall even if the inspection returns no gap hint. If no suitable wall
works, explain why before choosing a freestanding placement.
For a requested or clearly intended continuous furniture run (for example
kitchen cabinets and an adjacent integrated refrigerator), calculate all rear,
side and front edges in world coordinates, including rotation and the evaluated
model bounds. Where the physical installation permits, join the facing sides
without an arbitrary gap and align fronts and wall-facing backs. Check the
end of the run against the side wall as well as the wall behind it. Use actual
wall faces and avoid cumulative rounding; inspect the saved plan in 2D and 3D.
These are design intentions, not proof that every nearby cabinet belongs to the
same run: preserve specified gaps and make room for doors, handles, ventilation,
services, uneven walls and equipment instructions. If details are missing,
state the assumption and do not assert real-world installation clearance.
After furnishing, call `spielraum.inspect_furnished_layout` on the saved revision.
Review door/physical-intersection issues, route results and provisional furniture
use zones. Check wallAlignment for unintended gaps; it is advisory and must not
override explicit user placement or real clearances. Review adjacencyHints,
when returned, for candidate side-wall and furniture-to-furniture gaps, including
custom models. Decide whether the pieces actually form a run; measure
and correct unintended gaps, then re-inspect the whole layout. Missing hints do
not establish that all gaps were checked, especially for rotated/custom shapes.
Review nearby chair/table orientation candidates and their intended pairings;
proximity alone does not prove a relationship. Inspect chair pullout
scenarios as provisional final-position checks; they do not check the seated
person or the path of movement. A sampled wardrobe-opening conflict applies
only to the assumed two-door configuration; no sampled conflict does not prove
the entire sweep or actual hardware is clear. Resolve relevant
conflicts, then inspect again after the final edit.
An unverified route is not proof of a blockage or a clear route. Bed-side needs,
wardrobe fronts, chair/desk use, window operation and appliance access require
confirmation; do not claim the report checks them fully. A clear room route
reaches only some space in the room; a clear furniture target reaches a point in
its assumed zone, not necessarily the whole zone or the furniture's full use.
Estimated dimensions limit
real-world conclusions. If no feasible arrangement is found, explain the tradeoff
and offer smaller or fewer items; do not change structural geometry to make it fit.

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

## Save furniture from a product page or image

When the user wants to keep an item for later, review the chosen product
variant's page, a direct image URL or the uploaded image using the host's
available tools. If the source is inaccessible, ask for a screenshot. Clarify
ambiguous variants and ask for overall measurements where size matters.

Use prepare_library_item with one editable ThreeJSON model and width, depth and
height in meters. For each dimension, use listing for published dimensions of
that variant, user for user-supplied measurements, or estimated. Keep the source
link or a short upload note. Identify the approximation and review uncertain
dimensions in chat. The planner shows the draft under Furniture → Library →
My items. Let the user save it there, or call save_library_item with the draft
revision after the user approves. Set acceptEstimated only after the user
accepts the remaining estimates.

Saving an item leaves the home unchanged. For a placement requested in chat,
use list_library_items to find the saved ID and revision, then use add-library
in apply_furniture_changes with libraryItemId, expectedLibraryRevision, a fresh
placed-item ID and the destination floor and room. Placement creates an editable
copy and follows the usual lock, fit and history rules. Treat estimated size as
provisional when discussing real-world fit.

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

Set `finishes.floor` to `{ material: "oak" | "tile" | "concrete" | "carpet", color?: "#RRGGBB" }`
and `finishes.walls` to `{ material: "paint" | "concrete", color?: "#RRGGBB" }`.
Interior walls can set `finish` to override the level's wall finish. Oak and
warm-white paint are the level defaults.
Set `rooms[].floorFinish` to `{ material: "tile" }` for bathrooms, en suites,
toilets and shower rooms unless the source or user specifies another finish.
Use this field for a real floor surface. Keep open-plan kitchens, dining areas
and living rooms on the same continuous finish unless the plan specifies a
transition. A separate kitchen can use its own finish when appropriate.
Preserve level and room finishes on later edits. Tile and concrete are simple
modeled finishes. Oak and carpet are textured and can be tinted. Use carpet
for a continuous fitted surface and a rug furniture item for a movable rug.

## Describe geometry

All coordinates are meters from each floor's northwest clear interior corner:
x increases east, z increases south. Convert other units before calling tools.
`width` and `depth` are clear interior dimensions (1–30 m). Defaults are 2.5 m
ceiling height, 0.2 m exterior walls, 0.12 m interior walls, 2.05 m door height
and 1.2 m window height. Declare assumptions; do not call them measured.
For 3D dimensions, set `ceilingHeightBasis`, `wallThicknessBasis`, wall
`thicknessBasis`/`heightBasis`, opening `heightBasis`/window `sillBasis`, and
stair `riseBasis` when the source is known. Use `plan` for printed values,
`measured` for user measurements, `deduced` for values supported by visible
plan evidence, and `assumed` for provisional defaults. An unmarked value is
reported as assumed. A door swing can support position and handing, but does
not establish its height. A 2D stair arrow supports direction, not rise.
Preserve these basis fields on edits and never label a conventional default
as measured.

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
  Set `receivingFloorId` to the stable ID of the floor reached when known.
  The receiving floor needs an explicit rectangular `floorOpenings` entry.
  Each level is viewed separately; this is not a stacked whole-building view.

Use the supplied plans and description. Ask for missing dimensions/positions.
Create the known parts progressively instead of rejecting a whole home because
some details remain unknown. Do not infer a complete plan from floor names.
Do not silently substitute the original reference apartment or house.

Floor switching, 2D/3D, room focus, orbit/pan/zoom, walls and measurements stay
local in the UI. The 3D view uses soft shadows; the 2D plan does not. No model
tool is needed for view controls.
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
actual entrance door, then call `inspect_floor_plan`. Check the source for
unreachable rooms, reported wall gaps and offsets, and openings crossed by
partitions. Review `open_room_boundary` warnings against the source; open layouts
can be intentional. Review vertical dimensions and door, stair and receiving
stairwell warnings against printed heights, sections, notes and measurements.
Report material assumptions and unresolved warnings. For intended joins, align the wall spans or centerlines in
`set_floor`. Preserve documented free ends and doorways. Run inspection again
after structural corrections and verify the corners in both the full and
cutaway views. Missing entrance or analysis-limit results leave access
unverified. Compare the saved 2D boundary, partitions and openings to the source
before calling the reconstruction complete and disclose remaining uncertainty.

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

## Open-plan room grouping

Kitchen, dining and living zones with a shared wall-free edge appear as one selectable room; corridors remain separate even without doors. Keep their zone IDs and actual polygons. Do not merge zones or remove real walls merely to change navigation. For unusual names or intentional separation, use the spatial `zone` command with `roomGrouping: "open-plan"` or `"separate"`; `null` restores automatic English/German name recognition. Preview before committing and respect affected-zone locks. The override controls eligibility, not geometry: partial walls, doorways, corner-only contact and disconnected zones remain separate. Surface finish edits still target the chosen member zone.
