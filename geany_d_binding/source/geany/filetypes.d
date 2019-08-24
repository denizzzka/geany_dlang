module geany_d_binding.geany.filetypes;

import geany_d_binding.geany.types;

/** IDs of known filetypes
 *
 * @ref filetypes will contain an item for each. Use GeanyData::filetypes_array to
 * determine the known filetypes at runtime */
enum GeanyFiletypeID
{
    GEANY_FILETYPES_NONE = 0,   /* first filetype is always None & must be 0 */

    GEANY_FILETYPES_PHP,
    GEANY_FILETYPES_BASIC,  /* FreeBasic */
    GEANY_FILETYPES_MATLAB,
    GEANY_FILETYPES_RUBY,
    GEANY_FILETYPES_LUA,
    GEANY_FILETYPES_FERITE,
    GEANY_FILETYPES_YAML,
    GEANY_FILETYPES_C,
    GEANY_FILETYPES_NSIS,
    GEANY_FILETYPES_GLSL,
    GEANY_FILETYPES_PO,
    GEANY_FILETYPES_MAKE,
    GEANY_FILETYPES_TCL,
    GEANY_FILETYPES_XML,
    GEANY_FILETYPES_CSS,
    GEANY_FILETYPES_REST,
    GEANY_FILETYPES_HASKELL,
    GEANY_FILETYPES_JAVA,
    GEANY_FILETYPES_CAML,
    GEANY_FILETYPES_AS,
    GEANY_FILETYPES_R,
    GEANY_FILETYPES_DIFF,
    GEANY_FILETYPES_HTML,
    GEANY_FILETYPES_PYTHON,
    GEANY_FILETYPES_CS,
    GEANY_FILETYPES_PERL,
    GEANY_FILETYPES_VALA,
    GEANY_FILETYPES_PASCAL,
    GEANY_FILETYPES_LATEX,
    GEANY_FILETYPES_ASM,
    GEANY_FILETYPES_CONF,
    GEANY_FILETYPES_HAXE,
    GEANY_FILETYPES_CPP,
    GEANY_FILETYPES_SH,
    GEANY_FILETYPES_FORTRAN,
    GEANY_FILETYPES_SQL,
    GEANY_FILETYPES_F77,
    GEANY_FILETYPES_DOCBOOK,
    GEANY_FILETYPES_D,
    GEANY_FILETYPES_JS,
    GEANY_FILETYPES_VHDL,
    GEANY_FILETYPES_ADA,
    GEANY_FILETYPES_CMAKE,
    GEANY_FILETYPES_MARKDOWN,
    GEANY_FILETYPES_TXT2TAGS,
    GEANY_FILETYPES_ABC,
    GEANY_FILETYPES_VERILOG,
    GEANY_FILETYPES_FORTH,
    GEANY_FILETYPES_LISP,
    GEANY_FILETYPES_ERLANG,
    GEANY_FILETYPES_COBOL,
    GEANY_FILETYPES_OBJECTIVEC,
    GEANY_FILETYPES_ASCIIDOC,
    GEANY_FILETYPES_ABAQUS,
    GEANY_FILETYPES_BATCH,
    GEANY_FILETYPES_POWERSHELL,
    GEANY_FILETYPES_RUST,
    GEANY_FILETYPES_COFFEESCRIPT,
    GEANY_FILETYPES_GO,
    GEANY_FILETYPES_ZEPHIR,
    /* ^ append items here */
    GEANY_MAX_BUILT_IN_FILETYPES    /* Don't use this, use filetypes_array->len instead */
}

enum GeanyFiletypeGroupID
{
    GEANY_FILETYPE_GROUP_NONE,
    GEANY_FILETYPE_GROUP_COMPILED,
    GEANY_FILETYPE_GROUP_SCRIPT,
    GEANY_FILETYPE_GROUP_MARKUP,
    GEANY_FILETYPE_GROUP_MISC,
    GEANY_FILETYPE_GROUP_COUNT
}

/** Represents a filetype. */
struct GeanyFiletype
{
    GeanyFiletypeID   id;               /**< Index in @ref filetypes. */
    /* Represents the TMParserType of tagmanager (see the table
     * in src/tagmanager/tm_parser.h). */
    TMParserType      lang;
    /** Untranslated short name, such as "C", "None".
     * Must not be translated as it's used for hash table lookups - use
     * filetypes_get_display_name() instead. */
    gchar            *name;
    /** Shown in the file open dialog, such as "C source file". */
    gchar            *title;
    gchar            *extension;        /**< Default file extension for new files, or @c NULL. */
    gchar           **pattern;          /**< Array of filename-matching wildcard strings. */
    gchar            *context_action_cmd;
    gchar            *comment_open;
    gchar            *comment_close;
    gboolean          comment_use_indent;
    GeanyFiletypeGroupID group;
    gchar            *error_regex_string;
    GeanyFiletype*   lexer_filetype;
    gchar            *mime_type;
    GIcon            *icon;
    gchar            *comment_single; /* single-line comment */
    /* filetype indent settings, -1 if not set */
    gint              indent_type;
    gint              indent_width;

    GeanyFiletypePrivate* priv;  /* must be last, append fields before this item */
}

struct GeanyFiletypePrivate;
struct TMSourceFile;
struct GIcon;
