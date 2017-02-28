import common;

void main(string[] args)
{
    enforce(args.length > 1);
    auto dest = Path(args[1]);

    auto jsonText = cast(string)stdin.byChunk(4096).joiner.array;
    auto config = fromJSON!Config(jsonText.parseJSON());

    setupAuth(config.source);
    setupRepo(config.source);
    checkoutVersion(config.version_);

    auto file = Path(repoDir) ~ config.source.file;
    auto destFile = dest ~ "id";
    dest.tryMkdir();

    enforce (file.exists, "Ressource does not exist");
    copy(file, destFile);
    auto id = file.readText().chomp();
    
    writefln(`{\n
    "version": { "gitRef": "%s" },\n
    "metadata": [\n
        { "name": "id", "value": "%s" }\n
    ]\n
    }`, config.version_.gitRef, id);
}
