module common;

public import scriptlike, std.json, painlessjson;

immutable repoDir = "/tmp/repo";
immutable privateKeyPath = "/tmp/private-key";

struct Version
{
    string gitRef;
}

struct Source
{
    string file;
    string uri;
    string private_key;
    string git_name;
    string git_email;
}

struct Params
{
    string id_file;
}

struct Config
{
    Source source;
    @SerializedName("version") Version version_;
}

struct OutConfig
{
    Source source;
    @SerializedName("version") Version version_;
    Params params;
}

void setupRepo(Source source)
{
    if (!exists(repoDir))
        runCollect("git clone " ~ source.uri ~ " " ~ repoDir);
    else
    {
        chdir(repoDir);
        runCollect("git fetch origin");
    }

    chdir(repoDir);
    runCollect("git reset --hard origin/master");
}

void setupAuth(Source source)
{
    std.file.write(privateKeyPath, source.private_key);
    runCollect(`chmod 600 ` ~ privateKeyPath);
    environment["GIT_SSH_COMMAND"] = "ssh -o StrictHostKeyChecking=no -i " ~ privateKeyPath;
}

void checkoutVersion(Version ver)
{
    runCollect("git checkout " ~ ver.gitRef);
}

string commitPushRepo(Source source)
{
    if (!source.git_name.empty)
        runCollect(`git config --global user.name ` ~ source.git_name);
    if (!source.git_email.empty)
        runCollect(`git config --global user.email ` ~ source.git_email);

    runCollect(`git add *`);
    runCollect(`git commit -m "Add new version for ` ~ source.file ~ `"`);
    runCollect(`git push`);
    return runCollect(`git rev-parse HEAD`).chomp();
}
    
