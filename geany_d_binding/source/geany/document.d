module geany_d_binding.geany.document;

import geany_d_binding.geany.types;
import geany_d_binding.geany.filetypes;
import geany_d_binding.geany.editor: GeanyEditor;

import gtkc.gobjecttypes: GCallback;
import gtkc.gtktypes: GtkDialog, GtkWidget, GDestroyNotify;
import gtk.Version;
import glib.c.types: GModule;

extern(System) @nogc nothrow:

/**
 *  Structure for representing an open tab with all its properties.
 **/
struct GeanyDocument
{
    /** Flag used to check if this document is valid when iterating @ref GeanyData::documents_array. */
    gboolean         is_valid;
    gint             index;     /**< Index in the documents array. */
    /** Whether this document supports source code symbols(tags) to show in the sidebar. */
    gboolean         has_tags;
    /** The UTF-8 encoded file name.
     * Be careful; glibc and GLib file functions expect the locale representation of the
     * file name which can be different from this.
     * For conversion into locale encoding, you can use @ref utils_get_locale_from_utf8().
     * @see real_path. */
    gchar           *file_name;
    /** The encoding of the document, must be a valid string representation of an encoding, can
     *  be retrieved with @ref encodings_get_charset_from_index. */
    gchar           *encoding;
    /** Internally used flag to indicate whether the file of this document has a byte-order-mark. */
    gboolean         has_bom;
    GeanyEditor     *editor;    /**< The editor associated with the document. */
    /** The filetype for this document, it's only a reference to one of the elements of the global
     *  filetypes array. */
    GeanyFiletype   *file_type;
    /** TMSourceFile object for this document, or @c NULL. */
    TMSourceFile    *tm_file;
    /** Whether this document is read-only. */
    gboolean         readonly;
    /** Whether this document has been changed since it was last saved. */
    gboolean         changed;
    /** The link-dereferenced, locale-encoded file name.
     * If non-NULL, this indicates the file once existed on disk (not just as an
     * unsaved document with a filename set).
     *
     * @note This is only assigned after a successful save or open - it should
     * not be set elsewhere.
     * @see file_name. */
    gchar           *real_path;
    /** A pseudo-unique ID for this document.
     * @c 0 is reserved as an unused value.
     * @see document_find_by_id(). */
    guint            id;

    GeanyDocumentPrivate* priv;  /* should be last, append fields before this item */
}

struct GeanyDocumentPrivate;

/**
 *  Finds the current document.
 *
 *  @return @transfer{none} @nullable A pointer to the current document or @c NULL if there are no opened documents.
 **/
GeanyDocument* document_get_current();
