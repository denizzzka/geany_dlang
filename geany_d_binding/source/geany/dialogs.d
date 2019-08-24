module geany_d_binding.geany.dialogs;

import geany_d_binding.geany.types;
import gtkc.gtktypes: GtkMessageType;

extern(System) nothrow @nogc:

/**
 *  Shows a message box of the type @a type with @a text.
 *  On Unix-like systems a GTK message dialog box is shown, on Win32 systems a native Windows
 *  message dialog box is shown.
 *
 *  @param type A @c GtkMessageType, e.g. @c GTK_MESSAGE_INFO, @c GTK_MESSAGE_WARNING,
 *              @c GTK_MESSAGE_QUESTION, @c GTK_MESSAGE_ERROR.
 *  @param text Printf()-style format string.
 *  @param ... Arguments for the @a text format string.
 **/
void dialogs_show_msgbox(GtkMessageType type, const gchar *text, ...);
