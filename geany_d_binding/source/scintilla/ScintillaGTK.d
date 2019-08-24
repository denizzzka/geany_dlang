module geany_d_binding.scintilla.ScintillaGTK;

import geany_d_binding.scintilla.types;
import geany_d_binding.scintilla.ScintillaWidget: ScintillaObject;

extern(System) @nogc nothrow:

sptr_t scintilla_send_message(ScintillaObject* sci, uint iMessage, uptr_t wParam, sptr_t lParam);
