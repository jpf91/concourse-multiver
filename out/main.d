import common;

void main(string[] args)
{
    enforce(args.length > 1);
    auto srcDir = Path(args[1]);

    auto jsonText = cast(string)stdin.byChunk(4096).joiner.array;
    auto config = fromJSON!OutConfig(jsonText.parseJSON());

    setupAuth(config.source);
    setupRepo(config.source);

    auto destFile = Path(repoDir) ~ config.source.file;
    auto srcFile = srcDir ~ config.params.id_file;
    enforce(srcFile.exists, "Source file (" ~ srcFile.toString() ~ ") does not exist!");
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
