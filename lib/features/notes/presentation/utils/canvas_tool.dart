/// Toolbar-selectable tool. Eraser and pan are presentation-only — neither
/// produces a DrawingStrokeEntity; pan makes a single finger move/zoom the
/// canvas instead of drawing. In its own file so drawing_canvas.dart, the
/// toolbar, and the session helper can all depend on it without a circular
/// import.
enum CanvasTool { pen, highlighter, eraser, pan }
