module geany_d_binding.scintilla.Scintilla;

import geany_d_binding.scintilla.types;

extern(System) @nogc nothrow:

struct SCNotification
{
    Sci_NotifyHeader nmhdr;
    Sci_Position position;
    /* SCN_STYLENEEDED, SCN_DOUBLECLICK, SCN_MODIFIED, SCN_MARGINCLICK, */
    /* SCN_NEEDSHOWN, SCN_DWELLSTART, SCN_DWELLEND, SCN_CALLTIPCLICK, */
    /* SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK, SCN_HOTSPOTRELEASECLICK, */
    /* SCN_INDICATORCLICK, SCN_INDICATORRELEASE, */
    /* SCN_USERLISTSELECTION, SCN_AUTOCSELECTION */

    int ch;
    /* SCN_CHARADDED, SCN_KEY, SCN_AUTOCCOMPLETED, SCN_AUTOCSELECTION, */
    /* SCN_USERLISTSELECTION */
    int modifiers;
    /* SCN_KEY, SCN_DOUBLECLICK, SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK, */
    /* SCN_HOTSPOTRELEASECLICK, SCN_INDICATORCLICK, SCN_INDICATORRELEASE, */

    int modificationType;   /* SCN_MODIFIED */
    const(char)*text;
    /* SCN_MODIFIED, SCN_USERLISTSELECTION, SCN_AUTOCSELECTION, SCN_URIDROPPED */

    Sci_Position length;        /* SCN_MODIFIED */
    Sci_Position linesAdded;    /* SCN_MODIFIED */
    int message;    /* SCN_MACRORECORD */
    uptr_t wParam;  /* SCN_MACRORECORD */
    sptr_t lParam;  /* SCN_MACRORECORD */
    Sci_Position line;      /* SCN_MODIFIED */
    int foldLevelNow;   /* SCN_MODIFIED */
    int foldLevelPrev;  /* SCN_MODIFIED */
    int margin;     /* SCN_MARGINCLICK */
    int listType;   /* SCN_USERLISTSELECTION */
    int x;          /* SCN_DWELLSTART, SCN_DWELLEND */
    int y;      /* SCN_DWELLSTART, SCN_DWELLEND */
    int token;      /* SCN_MODIFIED with SC_MOD_CONTAINER */
    Sci_Position annotationLinesAdded;  /* SCN_MODIFIED with SC_MOD_CHANGEANNOTATION */
    int updated;    /* SCN_UPDATEUI */
    int listCompletionMethod;
    /* SCN_AUTOCSELECTION, SCN_AUTOCCOMPLETED, SCN_USERLISTSELECTION, */
}

struct Sci_NotifyHeader
{
    /* Compatible with Windows NMHDR.
     * hwndFrom is really an environment specific window handle or pointer
     * but most clients of Scintilla.h do not have this type visible. */
    void *hwndFrom;
    uptr_t idFrom;
    uint code;
}

enum Msg : uint
{
    SCN_CHARADDED = 2001,
    SCN_SAVEPOINTREACHED = 2002,
    SCN_SAVEPOINTLEFT = 2003,
    SCN_KEY = 2005,
    SCN_UPDATEUI = 2007,
    SCN_MODIFIED = 2008,
    SCN_PAINTED = 2013,
    SCN_USERLISTSELECTION = 2014,
    SCN_ZOOM = 2018,
    SCN_AUTOCSELECTION = 2022,
    SCN_AUTOCCANCELLED = 2025,
    SCN_FOCUSIN = 2028,
    SCN_FOCUSOUT = 2029,
    SCN_AUTOCCOMPLETED = 2030
}

enum Sci
{
    SCI_AUTOCSHOW = 2100,
    SCI_AUTOCGETSEPARATOR = 2107,
    SCI_USERLISTSHOW = 2117,
    SCI_CALLTIPSHOW = 2200,
    SCI_WORDSTARTPOSITION = 2266,
    SCI_AUTOCSETORDER = 2660,
    SCI_AUTOCGETORDER = 2661
}

/// Status Codes
enum Sc
{
	SC_ORDER_PERFORMSORT = 1
}
