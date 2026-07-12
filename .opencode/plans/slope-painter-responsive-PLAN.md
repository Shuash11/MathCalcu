# Plan: Fix _SlopePainter to be responsive (prevent overlapping labels)

## Feature Summary
Make the _SlopePainter in `slopegraph.dart` responsive so that tick labels, point labels, and equation labels do not overlap each other or with lines, regardless of graph size. Currently font sizes are fixed at 9-10px regardless of canvas dimensions.

## Subtask Breakdown
1. **Analyze current _SlopePainter implementation** - Read the full file, understand how labels are positioned, identify overlap issues.
2. **Calculate dynamic font sizes** - Scale font sizes based on `size` parameter (canvas dimensions).
3. **Adjust tick spacing** - Modify tick step calculation based on available width/height to prevent label overlap.
4. **Reposition point labels** - Adjust label positioning to avoid overlap with each other and with lines.
5. **Ensure equation labels don't overlap** - Modify `_drawLineLabel` to position labels away from lines and points.
6. **Test responsiveness** - Verify with different canvas sizes (small, medium, large).
7. **Run flutter analyze and flutter test** - Ensure no regressions.

## Files / Modules Expected to be Touched
- `lib/topics/calculus/midterm/graph/slope_graph/slopegraph.dart` (only file)

## Approach Notes
- Use a scale factor based on canvas dimensions (e.g., `size.width / 400` or `size.height / 400`)
- Dynamic font sizes: base font size multiplied by scale factor, clamped between reasonable min/max.
- Adjust tick step: if canvas is small, skip more ticks (e.g., every 4 units instead of every 2).
- Reposition point labels: check bounds and shift labels away from edges and other labels.
- Equation labels: ensure they are placed at safe distance from lines and points.

## Risks / Open Questions
- Need to ensure scaling doesn't break existing layout for typical sizes.
- Must maintain readability at small sizes (font size shouldn't become too tiny).
- Overlap detection may be complex; simpler approach: offset labels based on canvas size.

## Non-goals
- No changes to other painters (already fixed in tasks 4-6).
- No changes to the overall graph structure or data.
- No changes to the SlopeGraphScreen widget (only painter).