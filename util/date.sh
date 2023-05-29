#
# Script to find "best" time stamp of a file
# - If file is checked into git and unchanged, use git check-in date
# - If file is checked into git and changed, use file modification date
# - If file is not checked into git, use file modification date
#

change_date() {
case $(uname) in
NetBSD|OpenBSD|DragonFly|FreeBSD|Darwin)
        eval $(stat -s $1)
	echo $st_mtime
        ;;
*)
        stat -c %Y $1
esac
}

FILE=$1

if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then

    if ! git diff --quiet $FILE; then
        TIMESOURCE="file date"
        DATE=$(change_date "$FILE")
    else

        TIMESOURCE=git
        DATE=$(LANG= git log --no-show-signature -1 --format="format:%ct" $FILE 2>/dev/null || \
        	LANG= git log -1 --format="format:%ct" $FILE)
    fi
else
        TIMESOURCE="file date"
        DATE=$(change_date $FILE)
fi

# echo $TIMESOURCE

case $(uname) in
NetBSD|OpenBSD|DragonFly|FreeBSD|Darwin)
        LANG= date -r $DATE +"%a %b %d %T %Y"
        ;;
*)
        LANG= date +"%a %b %d %T %Y" -d @$DATE
esac

