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
        req.kind = RequestKind.doc;
        req.sourceCode = code;
        req.cursorPosition = 0x11B;

        auto ret = w.doRequest(req);

        writeln(ret);

        assert(ret.docComments == ["Main function\\n\\nThis function used for integration testing\\n\\nParams:\\n\\nargs = command line arguments\\n\\nReturns:\\n\\nAlways returns zero"]);
    }

    {
        AutocompleteRequest req;
        req.kind = RequestKind.autocomplete;
        req.sourceCode = code;
        req.cursorPosition = 0x140;

        auto ret = w.doRequest(req);
        writeln(ret);

        import std.algorithm.searching: canFind;
        assert(canFind(ret.completions, "First"));
        assert(canFind(ret.completions, "Second"));
    }

    destroy(w);
}
