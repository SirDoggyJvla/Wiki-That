set -e

# make sure main branch is being uploaded
git checkout main
git pull

# store current folder
WORKSHOP_DIR=$(pwd)

MOD_TITLE="Wiki That!"
WORKSHOP_ID=3567109091
VISIBILITY=0
TAGS="Build 42,Interface,Literature,Misc,QoL"

cd $STEAMUPLOADER
./SteamUploader --appID 108600 --workshopID "$WORKSHOP_ID" \
    --description "$WORKSHOP_DIR/description.bbcode" \
    --patchNote "$WORKSHOP_DIR/steam_description/patch_notes/$VERSION.bbcode" \
    -c "$WORKSHOP_DIR/Contents" \
    --preview "$WORKSHOP_DIR/Wiki That! - preview.png" \
    --title "$MOD_TITLE" --visibility "$VISIBILITY" --tags "$TAGS"

cd $WORKSHOP_DIR

ARCHIVE="/tmp/release.zip"
zip -r "$ARCHIVE" Contents/mods

gh release create "$VERSION" "$ARCHIVE" \
    --notes "$VERSION" \
    "$@"

rm -f "$ARCHIVE"