version(IntegrationTest):

import dcd_wrapper;
import common.messages;
import std.stdio;
import std.file: readText;
import std.conv: to;

void main()
{
    ubyte[] code = cast(ubyte[]) readText!(char[])("test_file.d");

    auto w = new DcdWrapper();

    {
        AutocompleteRequest req;
        req.kind = RequestKind.search;
        req.sourceCode = code;
        req.searchName = "List";

        auto ret = w.doRequest(req);

        writeln(ret);
    }

    {
        AutocompleteRequest req;
        req.kind = RequestKind.autocomplete;
        req.sourceCode = code;
        req.cursorPosition = 0x58;

        auto ret = w.doRequest(req);
        writeln(ret);

        import std.algorithm.searching: canFind;
        assert(canFind(ret.completions, "First"));
        assert(canFind(ret.completions, "Second"));
    }

    destroy(w);
}
