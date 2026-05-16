---
title: "Live Code Highlighting: A Technical Deep Dive"
date: 2026-02-10
created: 2026-02-10T00:00:00Z
type: blog
status: settled
publish: [ddrscott]
source: import
description: "How Strudel implements real-time code highlighting during music playback - a unique approach to connecting notation and sound in live coding environments."
image: /images/strudel-live-code-highlighting.png
prompt: "Import from blog post: 2026/strudel-live-code-highlighting.md"
---

# Strudel's Live Code Highlighting: A Technical Deep Dive

<img class="featured" src="/images/strudel-live-code-highlighting.png" alt="Featured image showing code editor with glowing syntax highlighting and musical waveforms" />

**How Strudel implements real-time code highlighting during music playback - a unique approach to connecting notation and sound in live coding environments.**

## Abstract

Live coding environments for music have long grappled with a fundamental challenge: how to visually connect the code musicians write with the sounds they hear. While most live coding systems provide static syntax highlighting and flash feedback on evaluation, Strudel - a JavaScript port of TidalCycles - implements a sophisticated system that dynamically highlights code elements as they produce sound in real-time. This whitepaper examines Strudel's implementation in detail, surveys prior art in the field, and analyzes the architectural decisions that make this feature possible.

## 1. Introduction

### 1.1 The Problem of Liveness

In traditional programming environments, there's a clear separation between writing code and executing it. The feedback loop consists of: write code, run it, observe output. Live coding environments compress this loop dramatically, but even in systems like TidalCycles or Sonic Pi, the visual connection between code and sound remains indirect.

Consider a pattern like:

```javascript
s("bd hh sd hh").note("c3 e3 g3 b3")
```

When this plays, a musician hears a sequence of sounds. But *which* part of the code is producing the current sound? Is it the `bd` (bass drum) or the `hh` (hi-hat)? The `c3` or the `g3`? Traditional syntax highlighting provides no answer - it colors keywords by their syntactic role, not their temporal activity.

### 1.2 Strudel's Solution

Strudel solves this by implementing what we might call **temporal source mapping** - a system that maintains bidirectional links between:

1. **Source code positions** (character ranges in the editor)
2. **Musical events** (called "Haps" in Tidal terminology)

When a Hap becomes active (i.e., its time span includes "now"), the corresponding source code is visually highlighted with a colored outline. This creates an immediate, visceral connection between notation and sound.

![Conceptual diagram of temporal source mapping](https://strudel.cc/learn/mini-notation)

## 2. Prior Art and Related Work

### 2.1 Gibber: Annotations and Visualizations

Charlie Roberts' research on Gibber represents the closest prior art to Strudel's approach. In his 2015 NIME paper "Beyond Editing: Extended Interaction with Textual Code Fragments," Roberts describes techniques for:

- **Inline annotations**: Displaying runtime values directly in source code
- **Sparkline visualizations**: Showing continuous signals as miniature graphs
- **Pattern playhead indicators**: Visual markers showing current position in sequences

Roberts' key insight was that source code could serve dual purposes: as notation (what to play) and as visualization (what is playing). His 2018 web essay "Realtime Annotations & Visualizations in Live Coding Performance" catalogs these techniques extensively.

However, Gibber's approach differs from Strudel's in a crucial way: Gibber's annotations are **injected widgets** that appear alongside or within code, whereas Strudel's highlighting **decorates the existing code** without modifying its visual structure.

### 2.2 Estuary: Collaborative Projectional Editing

The Estuary project (Ogborn et al., 2017) explored collaborative live coding in the browser with TidalCycles-style patterns. While Estuary focused primarily on collaborative editing and "projectional" interfaces, it contributed to the ecosystem of browser-based live coding that Strudel builds upon.

### 2.3 Traditional Debugger Approaches

Traditional debugging tools have long provided execution visualization:

- **Breakpoint highlighting**: Current line indicators in step debuggers
- **Coverage highlighting**: Showing which lines were executed
- **Profiler heat maps**: Coloring code by execution frequency

These approaches treat code as sequential instructions. Strudel's challenge is different: patterns are **declarative and cyclical**, not imperative and linear. A pattern like `"bd hh"` doesn't execute once - it continuously generates events across time.

### 2.4 CodeMirror Decoration System

Strudel's implementation leverages CodeMirror 6's decoration system, which provides:

- **Mark decorations**: Styling ranges of text
- **Widget decorations**: Inserting DOM elements
- **Line decorations**: Styling entire lines
- **Computed decorations**: Dynamically generated based on state

The key innovation in CodeMirror 6 is that decorations are computed from **immutable state**, enabling efficient updates without DOM thrashing.

## 3. Architecture Overview

Strudel's live highlighting system consists of five interconnected components:

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER CODE                                │
│                    s("bd hh").note("c")                         │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                        TRANSPILER                                │
│   Parses code, extracts miniLocations: [[3, 10], [17, 20]]      │
└──────────────────────────────┬──────────────────────────────────┘
                               │
               ┌───────────────┴───────────────┐
               ▼                               ▼
┌──────────────────────────┐    ┌─────────────────────────────────┐
│     PATTERN ENGINE       │    │          CODEMIRROR             │
│  Attaches locations to   │    │   Stores locations as invisible │
│  Haps via context        │    │   decorations with IDs          │
└────────────┬─────────────┘    └──────────────┬──────────────────┘
             │                                  │
             ▼                                  │
┌──────────────────────────┐                   │
│       SCHEDULER          │                   │
│  Queries pattern for     │                   │
│  active haps @ 60fps     │                   │
└────────────┬─────────────┘                   │
             │                                  │
             ▼                                  │
┌──────────────────────────┐                   │
│         DRAWER           │                   │
│   Animation loop calls   │───────────────────┘
│   highlight(haps, time)  │
└────────────┬─────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    VISUAL HIGHLIGHTING                           │
│   CodeMirror computes decorations for active locations          │
│   User sees: s("bd hh").note("c")                               │
│                 ^^^^^^ ← outlined while sounding                │
└─────────────────────────────────────────────────────────────────┘
```

## 4. Implementation Deep Dive

### 4.1 Source Location Extraction

The transpiler (`packages/transpiler/transpiler.mjs`) uses Acorn for JavaScript parsing and Peggy for mini notation parsing. During transpilation, it captures the character positions of each pattern element:

```javascript
export function transpiler(input, options = {}) {
  const { emitMiniLocations = true } = options;
  let miniLocations = [];

  const collectMiniLocations = (value, node) => {
    const leafLocs = getLeafLocations(`"${value}"`, node.start, input);
    miniLocations = miniLocations.concat(leafLocs);
  };

  // Walk AST, collect locations for mini notation strings...

  return { output, miniLocations, widgets, sliders, labels };
}
```

The output format is an array of `[start, end]` tuples representing character ranges:

```javascript
// For: s("bd hh").note("c3")
miniLocations = [
  [3, 5],    // "bd"
  [6, 8],    // "hh"
  [17, 19],  // "c3"
]
```

### 4.2 Location Propagation Through Patterns

Patterns in Strudel carry a `context` object that propagates through all transformations. The `withLoc()` method attaches source positions:

```javascript
// packages/core/pattern.mjs
withLoc(start, end) {
  const location = { start, end };
  return this.withContext((context) => {
    const locations = (context.locations || []).concat([location]);
    return { ...context, locations };
  });
}
```

This is crucial: when patterns are composed (via `stack`, `cat`, `slow`, `fast`, etc.), the location context is preserved and combined. A Hap created from `s("bd").stack(s("hh"))` will carry locations from *both* source patterns.

### 4.3 The Hap Data Structure

A Hap (Happening) is the fundamental event unit in Tidal/Strudel:

```javascript
// packages/core/hap.mjs
class Hap {
  constructor(whole, part, value, context = {}, stateful = false) {
    this.whole = whole;      // TimeSpan: when the event "conceptually" occurs
    this.part = part;        // TimeSpan: the portion being queried
    this.value = value;      // The sound/note/control data
    this.context = context;  // Includes locations!
    this.stateful = stateful;
  }

  isActive(time) {
    return this.whole.begin <= time && this.endClipped >= time;
  }
}
```

The `context.locations` array enables reverse-mapping from event to source code.

### 4.4 CodeMirror State Management

Strudel uses three CodeMirror 6 StateFields to manage highlighting:

#### 4.4.1 `miniLocations` - Structural Storage

```javascript
// packages/codemirror/highlight.mjs
const miniLocations = StateField.define({
  create() { return Decoration.none; },
  update(locations, tr) {
    for (let e of tr.effects) {
      if (e.is(setMiniLocations)) {
        const marks = e.value.locations.map(([from, to]) =>
          Decoration.mark({
            id: `${from}:${to}`,  // Key for matching!
            attributes: { style: `background-color: #00CA2880` },
          }).range(from, to)
        );
        locations = Decoration.set(marks, true);
      }
    }
    return locations;
  },
});
```

Each decoration carries an `id` in the format `"start:end"`, enabling O(1) lookup when matching active Haps.

#### 4.4.2 `visibleMiniLocations` - Active Hap Tracking

```javascript
const visibleMiniLocations = StateField.define({
  create() { return { atTime: 0, haps: new Map() }; },
  update(visible, tr) {
    for (let e of tr.effects) {
      if (e.is(showMiniLocations)) {
        const haps = new Map();
        for (let hap of e.value.haps) {
          if (!hap.context?.locations || !hap.whole) continue;
          for (let { start, end } of hap.context.locations) {
            const id = `${start}:${end}`;
            // Keep earliest-starting hap for each location
            if (!haps.has(id) || haps.get(id).whole.begin.lt(hap.whole.begin)) {
              haps.set(id, hap);
            }
          }
        }
        visible = { atTime: e.value.atTime, haps };
      }
    }
    return visible;
  },
});
```

This builds a Map from location IDs to their currently active Haps.

#### 4.4.3 `miniLocationHighlights` - Computed Decorations

```javascript
const miniLocationHighlights = EditorView.decorations.compute(
  [miniLocations, visibleMiniLocations, displayMiniLocationsState],
  (state) => {
    const shouldDisplay = state.field(displayMiniLocationsState);
    if (!shouldDisplay) return Decoration.none;

    const iterator = state.field(miniLocations).iter();
    const { haps } = state.field(visibleMiniLocations);
    const builder = new RangeSetBuilder();

    while (iterator.value) {
      const { from, to, value: { spec: { id } } } = iterator;
      if (haps.has(id)) {
        const hap = haps.get(id);
        const color = hap.value?.color ?? 'var(--foreground)';
        const style = hap.value?.markcss || `outline: solid 2px ${color}`;
        builder.add(from, to, Decoration.mark({ attributes: { style } }));
      }
      iterator.next();
    }
    return builder.finish();
  },
);
```

This is the heart of the system: it iterates through all stored locations, checks which have active Haps, and generates visible outline decorations for those.

### 4.5 The Animation Loop

The Drawer class (`packages/draw/draw.mjs`) runs at `requestAnimationFrame` speed (~60fps):

```javascript
export class Drawer {
  constructor(onDraw, drawTime) {
    this.framer = new Framer(() => {
      const phase = this.scheduler.now() + lookahead;

      // Query the pattern for currently active haps
      const haps = this.scheduler.pattern.queryArc(
        Math.max(this.lastFrame, phase - 1/10),
        phase
      );

      // Maintain visible haps with lookbehind for visual continuity
      this.visibleHaps = (this.visibleHaps || [])
        .filter(h => h.whole && h.endClipped >= phase - lookbehind - lookahead)
        .concat(haps.filter(h => h.hasOnset()));

      // Call the callback with current state
      onDraw(this.visibleHaps, phase - lookahead, this, this.painters);
    });
  }
}
```

The StrudelMirror class connects this to CodeMirror:

```javascript
// packages/codemirror/codemirror.mjs
this.drawer = new Drawer((haps, time, _, painters) => {
  const currentFrame = haps.filter((hap) => hap.isActive(time));
  this.highlight(currentFrame, time);  // Updates CodeMirror!
  this.onDraw(haps, time, painters);
}, drawTime);
```

## 5. Design Decisions and Trade-offs

### 5.1 Location IDs vs. Direct References

Strudel uses string-based location IDs (`"start:end"`) rather than direct object references. This enables:

- **Serialization**: Locations can be stored, transmitted, and compared
- **Immutability**: CodeMirror state remains pure
- **Efficiency**: Map lookups are O(1)

The trade-off is potential collisions if two distinct code elements share identical positions (rare in practice).

### 5.2 Outline vs. Background Highlighting

Strudel uses CSS `outline` rather than `background-color` for active highlighting:

```javascript
const style = hap.value?.markcss || `outline: solid 2px ${color}`;
```

Outlines don't affect layout, don't obscure text, and can overlap without visual confusion. This is important when multiple elements are active simultaneously.

### 5.3 60fps Update Rate

The animation loop runs at display refresh rate. This provides smooth visual updates but requires careful performance optimization:

- **Query window limiting**: Only query a small time window
- **Hap filtering**: Remove old haps from the visible list
- **Efficient state updates**: CodeMirror's computed decorations only recompute when dependencies change

### 5.4 Color Propagation

Hap colors come from the pattern's `value` object:

```javascript
const color = hap.value?.color ?? 'var(--foreground)';
```

This enables patterns like:

```javascript
s("bd hh").color("red blue")
```

Where different elements of the pattern can have different highlight colors.

## 6. Comparison with Alternative Approaches

### 6.1 Widget Injection (Gibber-style)

**Approach**: Insert DOM elements alongside or within code to show state.

**Pros**:

- Can display rich information (graphs, sliders)
- Doesn't require pattern-to-source mapping

**Cons**:

- Changes visual layout
- Requires custom parser/renderer
- Can clutter the editor

### 6.2 Line-Level Highlighting (Debugger-style)

**Approach**: Highlight entire lines that are "active."

**Pros**:

- Simple to implement
- Works with any language

**Cons**:

- Too coarse for pattern-based music
- Patterns often span multiple elements on one line

### 6.3 Cursor Following (Sequencer-style)

**Approach**: Move a cursor/playhead across the code as time progresses.

**Pros**:

- Intuitive for linear sequences
- Familiar from DAWs

**Cons**:

- Doesn't work for polyphonic patterns
- Assumes left-to-right temporal ordering

### 6.4 Strudel's Approach (Temporal Source Mapping)

**Approach**: Map musical events to source positions, highlight active positions.

**Pros**:

- Works for polyphonic, polyrhythmic patterns
- Preserves code readability
- Scales to complex compositions

**Cons**:

- Requires deep integration with pattern engine
- Performance overhead from continuous updates
- Limited to pattern elements (not arbitrary expressions)

## 7. Performance Characteristics

### 7.1 Time Complexity

| Operation | Complexity |
|-----------|------------|
| Location extraction (transpile) | O(n) where n = AST nodes |
| Location storage (CodeMirror) | O(m) where m = locations |
| Active hap lookup | O(k) where k = active haps |
| Decoration computation | O(m) worst case, typically O(k) |

### 7.2 Space Complexity

| Data Structure | Space |
|----------------|-------|
| miniLocations array | O(m) |
| CodeMirror decorations | O(m) |
| Active haps Map | O(k) |

### 7.3 Observed Behavior

In practice, with typical live coding patterns (10-50 locations), the system maintains smooth 60fps updates. Performance degrades with:

- Very long code (thousands of locations)
- High-density patterns (hundreds of simultaneous events)
- Low-powered devices

## 8. Extensibility and Customization

### 8.1 Custom Styling

Users can customize highlight appearance via `.markcss()`:

```javascript
s("bd hh").markcss("background: rgba(255,0,0,0.3); border-radius: 4px")
```

### 8.2 Toggle Control

Highlighting can be enabled/disabled:

```javascript
// Via CodeMirror effect
view.dispatch({ effects: displayMiniLocations.of(false) });
```

### 8.3 Integration with Other Visualizations

The same Hap data drives other visualizations (pianoroll, waveform) via the Drawer's `onDraw` callback, enabling synchronized multi-modal feedback.

## 9. Future Directions

### 9.1 Expression-Level Tracking

Currently, only mini notation elements are tracked. Extending to arbitrary JavaScript expressions would enable highlighting for:

```javascript
note(Math.random() * 12)  // Which random value is playing?
```

### 9.2 Historical Visualization

Showing recently-played elements with fading opacity could provide temporal context beyond the current instant.

### 9.3 Bidirectional Editing

Clicking a highlighted element during playback could select that Hap for modification, enabling direct manipulation of playing sounds.

### 9.4 Cross-Editor Support

The architecture could be ported to other editors (Monaco, Ace) by abstracting the CodeMirror-specific decoration system.

## 10. Conclusion

Strudel's live code highlighting represents a significant advancement in live coding interfaces. By maintaining bidirectional links between source code and musical events, it creates an immediate visual connection between notation and sound that enhances both performance and learning.

The key architectural insights are:

1. **Capture locations during parsing** - not execution
2. **Propagate locations through pattern composition** - maintaining context
3. **Use efficient lookup structures** - location IDs enable O(1) matching
4. **Leverage editor decoration systems** - CodeMirror's computed decorations
5. **Run at animation frame rate** - smooth visual updates

This approach is generalizable to other domains where code produces time-varying output: animation, simulation, robotics, or any system where "which code is active now?" is a meaningful question.

## References

1. Roberts, C., Wright, M., & Kuchera-Morin, J. (2015). "Beyond Editing: Extended Interaction with Textual Code Fragments." NIME 2015.

2. Roberts, C. (2018). "Realtime Annotations & Visualizations in Live Coding Performance." Web Essay. https://charlieroberts.github.io/annotationsAndVisualizations/

3. Ogborn, D., Beverley, J., del Angel, L. N., Tsabary, E., & McLean, A. (2017). "Estuary: Browser-based Collaborative Projectional Live Coding of Musical Patterns." ICLC 2017.

4. Roos, F. & McLean, A. (2023). "Strudel: Live Coding Patterns on the Web." ICLC 2023.

5. CodeMirror. "Decoration Example." https://codemirror.net/examples/decoration/

6. Roberts, C. & Wakefield, G. (2017). "gibberwocky: New Live-Coding Instruments for Musical Performance." NIME 2017.

7. McLean, A. (2014). "Making Programming Languages to Dance to: Live Coding with Tidal." FARM 2014.

8. Xambó, A. & Roma, G. (2024). "Human-machine agencies in live coding for music performance." Journal of New Music Research.

## Appendix A: Key Source Files

| File | Purpose |
|------|---------|
| `packages/transpiler/transpiler.mjs` | Source location extraction |
| `packages/core/pattern.mjs` | `withLoc()` method, context propagation |
| `packages/core/hap.mjs` | Hap class with `isActive()` |
| `packages/core/repl.mjs` | Evaluation and location passing |
| `packages/draw/draw.mjs` | Animation loop |
| `packages/codemirror/highlight.mjs` | StateFields and decorations |
| `packages/codemirror/codemirror.mjs` | StrudelMirror integration |

## Appendix B: Minimal Implementation

For developers interested in implementing similar functionality, here's a minimal example:

```javascript
// 1. During parsing, capture source positions
const locations = [];
ast.walk(node => {
  if (isPatternElement(node)) {
    locations.push([node.start, node.end]);
  }
});

// 2. Attach locations to events
class Event {
  constructor(time, value, locations) {
    this.time = time;
    this.value = value;
    this.locations = locations;
  }
  isActive(now) {
    return this.time <= now && now < this.time + this.duration;
  }
}

// 3. Animation loop
function animate() {
  const now = scheduler.currentTime();
  const activeEvents = events.filter(e => e.isActive(now));

  // 4. Update editor decorations
  const activeLocations = new Set(
    activeEvents.flatMap(e => e.locations.map(l => `${l[0]}:${l[1]}`))
  );

  editor.updateDecorations(activeLocations);
  requestAnimationFrame(animate);
}
```

---

*This whitepaper is based on analysis of Strudel version 1.3.0, hosted at [strudel.cc](https://strudel.cc) and [codeberg.org/strudel](https://codeberg.org/strudel).*
