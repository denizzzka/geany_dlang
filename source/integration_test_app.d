version(IntegrationTest):

import dcd_wrapper;
import dcd.common.messages;
import std.stdio;
import std.file: readText;
import std.conv: to;
import std.algorithm.searching: canFind;

void main()
{
    ubyte[] code = cast(ubyte[]) readText!(char[])("test_file.d");

    auto w = new DcdWrapper();
    scope(exit) destroy(w);

    {
        AutocompleteRequest req;
        req.kind = RequestKind.doc;
        req.sourceCode = code;
        req.cursorPosition = 0x11B;

        auto ret = w.doRequest(req);

        writeln(ret);

        assert(ret.completions.length == 1);
        assert(ret.completions[0].documentation.canFind("This function used for integration testing"));
    }

    {
        AutocompleteRequest req;
        req.kind = RequestKind.autocomplete;
        req.sourceCode = code;
        req.cursorPosition = 0x140;

        auto ret = w.doRequest(req);
        writeln(ret);

        assert(ret.completions.length >= 2);
        assert(ret.completions[$-2].identifier == "First");
        assert(ret.completions[$-1].identifier == "Second");
    }
}
