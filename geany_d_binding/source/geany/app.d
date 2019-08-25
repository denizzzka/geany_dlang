module geany_d_binding.geany.app;

import geany_d_binding.geany.types;

extern(System) @nogc nothrow:

/** Important application fields. */
struct GeanyApp
{
    gboolean            debug_mode;     /**< @c TRUE if debug messages should be printed. */
    gchar               *configdir;
    gchar               *datadir;
    gchar               *docdir;
    const TMWorkspace   *tm_workspace;  /**< TagManager workspace/session tags. */
    GeanyProject    *project;       /**< Currently active project or @c NULL if none is open. */
}

struct GeanyProject;
struct TMWorkspace;
