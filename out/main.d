import common;

void main(string[] args)
{
    enforce(args.length > 1);
    auto srcDir = Path(args[1]);

    auto jsonText = cast(string)stdin.byChunk(4096).joiner.array;
    auto config = fromJSON!Config(jsonText.parseJSON());

    setupAuth(config.source);
    setupRepo(config.source);
    

    auto destFile = Path(repoDir) ~ config.source.file;
    auto srcFile = srcDir ~ "id";
    enforce(srcFile.exists, "Source file (id) does not exist!");
    destFile.dirName.tryMkdir();

    copy(srcFile, destFile);
    auto id = srcFile.readText().chomp();
    auto gitRef = commitPushRepo(config.source);
    
    writefln(`{\n
    "version": { "gitRef": "%s" },\n
    "metadata": [\n
        { "name": "id", "value": "%s" }\n
    ]\n
    }`, gitRef, id);
}
