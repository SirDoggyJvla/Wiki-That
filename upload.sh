# make sure main branch is being uploaded
git checkout main
git pull

# store current folder
WORKSHOP_DIR=$(pwd)

MOD_TITLE="Wiki That!"
WORKSHOP_ID=3567109091
VISIBILITY=0
TAGS="Build 42,Interface,Literature,Misc,QoL"

$STEAMUPLOADER/SteamUploader --appID 108600 --workshopID "$WORKSHOP_ID" --description "$WORKSHOP_DIR/description.bbcode" --patchNote "$WORKSHOP_DIR/patch_note.bbcode" -c "$WORKSHOP_DIR/Contents" --preview "$WORKSHOP_DIR/Wiki That! - preview.png" --title "$MOD_TITLE" --visibility "$VISIBILITY" --tags "$TAGS"
