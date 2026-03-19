/**
 * PhiaEditorBundle — single import that registers all PhiaUI editor hooks.
 *
 * Usage:
 *   import { editorHooks } from "./hooks/phia_editor_bundle"
 *   let liveSocket = new LiveSocket("/live", Socket, {
 *     hooks: { ...editorHooks, ...otherHooks }
 *   })
 *
 * This bundles every editor-related hook so consumers don't need to
 * import them individually.
 */

import PhiaRichEditor from "./phia_rich_editor";
import PhiaImageResize from "./image_resize";
import PhiaTableEditor from "./table_editor";
import PhiaDrawingCanvas from "./drawing_canvas";
import PhiaEmojiPickerBlock from "./emoji_picker_block";
import PhiaCodeHighlight from "./code_highlight";
import PhiaDragHandle from "./drag_handle";
import PhiaDiagram from "./diagram_renderer";
import PhiaEquation from "./equation_renderer";
import PhiaTrackChanges from "./track_changes";

// Hooks from previous waves (imported for completeness)
// These are already defined in their own files and may be imported separately
// import PhiaBubbleMenu from "./bubble_menu";
// import PhiaFloatingMenu from "./floating_menu";
// import PhiaSlashCommand from "./slash_command";
// import PhiaEditorColorPicker from "./editor_color_picker";
// import PhiaEditorDropdown from "./editor_dropdown";
// import PhiaMarkdownEditor from "./markdown_editor";
// import PhiaEditorFindReplace from "./editor_find_replace";
// import PhiaAdvancedEditor from "./advanced_editor";

/**
 * All editor hooks as a single object. Spread into your LiveSocket hooks config.
 */
export const editorHooks = {
  PhiaRichEditor,
  PhiaImageResize,
  PhiaTableEditor,
  PhiaDrawingCanvas,
  PhiaEmojiPickerBlock,
  PhiaCodeHighlight,
  PhiaDragHandle,
  PhiaDiagram,
  PhiaEquation,
  PhiaTrackChanges,
};

/**
 * Register all hooks on the window for script-tag usage (non-bundler setups).
 */
export function registerEditorHooks() {
  if (typeof window !== "undefined") {
    window.PhiaEditorHooks = editorHooks;
    Object.entries(editorHooks).forEach(([name, hook]) => {
      window[name] = hook;
    });
  }
}

export default editorHooks;
