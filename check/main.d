import common;

void main(string[] args)
{
    enforce(args.length > 1);
    auto srcDir = Path(args[1]);

    auto jsonText = cast(string)stdin.byChunk(4096).joiner.array;
    auto config = fromJSON!Config(jsonText.parseJSON());

    writefln(`{
    "version": { "gitRef": "%s" }
    }`, config.version_.gitRef);
}
