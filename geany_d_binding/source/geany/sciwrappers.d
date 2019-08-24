module geany_d_binding.geany.sciwrappers;

import geany_d_binding.geany.types;
import geany_d_binding.scintilla.ScintillaWidget;

extern(System) nothrow @nogc:

/** Gets the length of all text.
 * @param sci Scintilla widget.
 * @return Length. */
gint sci_get_length(ScintillaObject* sci);

/** Allocates and fills a buffer with text from the start of the document.
 * @param sci Scintilla widget.
 * @param buffer_len Buffer length to allocate, including the terminating
 * null char, e.g. sci_get_length() + 1. Alternatively use @c -1 to get all
 * text (since Geany 1.23).
 * @return A copy of the text. Should be freed when no longer needed.
 *
 * @since 1.23 (0.17)
 */
gchar* sci_get_contents(ScintillaObject* sci, gint buffer_len);

/** Gets the cursor position.
 * @param sci Scintilla widget.
 * @return Position. */
gint sci_get_current_position(ScintillaObject *sci);
