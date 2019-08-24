module geany_d_binding.scintilla.ScintillaWidget;

import geany_d_binding.geany.types;
import gtkc.gtktypes: GtkContainer;

extern(System) @nogc nothrow:

struct ScintillaObject
{
    GtkContainer cont;
    void* pscin;
}
