#!/usr/bin/env bash

source $(readlink -f $(dirname "$0"))/kodi.env

if [[ -z "$KODI_HOST" ]]
then
    echo "Kodi hostname is not set" >&2
    exit 3
fi

KODI_URL="http://${KODI_USERNAME}:${KODI_PASSWORD}@${KODI_HOST}:${KODI_PORT}/jsonrpc"

usage() {
    echo "Usage: $(basename $0) refresh|clean [library]"
}

__request() {
    curl -H 'content-type: application/json;' \
         --data-binary \
            '{ "jsonrpc": "2.0", "method": "'"$1"'", "id": "kodi.sh"}' \
         "$KODI_URL"
}

refresh_video_library() {
    __request VideoLibrary.Scan
}

refresh_audio_library() {
    __request AudioLibrary.Scan
}

refresh_library() {
    case "$1" in
        video|vid|v)
            refresh_video_library
            ;;
        music|m|audio|a)
            refresh_audio_library
            ;;
        *)
            refresh_video_library
            refresh_audio_library
            ;;
    esac
}

clean_video_library() {
    __request VideoLibrary.Clean
}

clean_audio_library() {
    __request AudioLibrary.Clean
}

clean_library() {
    case "$1" in
        video|vid|v)
            clean_video_library
            ;;
        music|m|audio|a)
            clean_audio_library
            ;;
        *)
            clean_video_library
            clean_audio_library
            ;;
    esac
}

case "$1" in
    refresh|r)
        refresh_library "$2"
        ;;
    clean|c)
        clean_library "$2"
        ;;
    freshen|fresh|f)
        refresh_library "$2"
        clean_library "$2"
        ;;
    *)
        usage
        exit 2
        ;;
esac

