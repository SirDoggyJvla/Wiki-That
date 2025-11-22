# store current folder
CURRENT_DIR=$(pwd)

REPO_DIR="/home/simon/Documents/Repositories/Steam-Uploader-tool/releases/0.5.0-ubuntu"
WORKSHOP_DIR="$(pwd)"

cd "$REPO_DIR"
./SteamUploader -a 108600 -w 3567109091 -d "$WORKSHOP_DIR/description.bbcode" -P "$WORKSHOP_DIR/patch_note.bbcode" -c "$WORKSHOP_DIR/Contents"

cd $CURRENT_DIR