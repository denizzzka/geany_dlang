module geany_d_binding.geany.types;

alias gchar = char;
alias gint = int;
alias guint = uint;
alias gsize = size_t;
alias gboolean = gint;
alias gpointer = size_t*;
alias gfloat = float;
alias TMParserType = gint;

/// Wraps g_free to nothrow version
void g_free(T)(T mem) nothrow
{
	import gtkc.glib: official_g_free = g_free;

	try
		official_g_free(mem);
	catch(Exception)
	{
		assert(false);
	}
}
