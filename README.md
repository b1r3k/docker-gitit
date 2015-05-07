# docker-gitit

A Dockerfile for the [Gitit Wiki](https://github.com/jgm/gitit) including `graphviz` package for dot file support and `texlive` for PDF exporti capabilities. There is no default user, you can register directly in the wiki.

## Usage

For a first installation (if you don't already use Gitit) :

```bash
sudo docker run -d --name gitit \
                -e GIT_COMMITTER_NAME="User Name" \
                -e GIT_COMMITTER_EMAIL="user@domain.com" \
                -p 80:5001 \
                marcelhuberfoo/docker-gitit
```

***It is important to pass in the committers name and email at least for the first commits of gitit!*** Otherwise the container will abort due to `git commit` errors. As soon as you created a user and logged in, the commit author is the user name.
Default author name is **Gitit** and author email is empty but these do not force `git` to fail. If you like to set these values too, add them to the list of environment variables to pass in (exchange `COMMITTER` with `AUTHOR`).


To use an existing Gitit wiki (assuming it's installed at /home/gitit/wiki), mount it as a volume :

```bash
sudo docker run -d --name gitit \
                -e GIT_COMMITTER_NAME="User Name" \
                -e GIT_COMMITTER_EMAIL="user@domain.com" \
                -p 80:5001 \
                -v /home/gitit/wiki:/data \
                marcelhuberfoo/docker-gitit
```

Instead of passing in the committer and user name as environment variables, set it in your `.git/config` administrative file from within the mounted directory. E.g. `git --git-dir=/home/gitit/wiki/wikidata/.git config user.name "Some User"` and `git --git-dir=/home/gitit/wiki/wikidata/.git config user.email "user@domain.com"` respectively. You can do it likewise for the author.

## Volumes

### `/data`

`/data/gitit.conf` should contain the configuration file for gitit. If you don't provide it using the volume, a default one will be created.

Gitit will also create the following when started :

- `/data/static/` contains static (css and img) files used by gitit.
- `/data/templates/` contains HStringTemplate templates for wiki pages.
- `/data/wikidata/` contains the Git repo where all pages are stored.

## Ports

### 5001

Gitit default webserver port


