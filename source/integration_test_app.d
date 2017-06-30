version(IntegrationTest):

import dcd_wrapper;
import common.messages;
import std.stdio;

void main()
{
    auto w = new DcdWrapper();

    {
        AutocompleteRequest req;
        req.kind = RequestKind.search;
        req.searchName = "DcdWrapper";

        auto ret = w.doRequest(req);

        writeln(ret);
    }

    destroy(w);
}
