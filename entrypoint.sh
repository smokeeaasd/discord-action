#!/bin/sh -l

WEBHOOK_URL=$1
MESSAGE=$2
EMBED_TITLE=$3
EMBED_DESCRIPTION=$4
EMBED_URL=$5
EMBED_COLOR=$6
EMBED_FOOTER=$7
EMBED_IMAGE=$8
EMBED_THUMBNAIL=$9

if [ -z "$WEBHOOK_URL" ]; then
  echo "Webhook URL is required."
  exit 1
fi

if [ -z "$MESSAGE" ] && [ -z "$EMBED_TITLE" ] && [ -z "$EMBED_DESCRIPTION" ] && [ -z "$EMBED_URL" ] && [ -z "$EMBED_COLOR" ] && [ -z "$EMBED_FOOTER" ] && [ -z "$EMBED_IMAGE" ] && [ -z "$EMBED_THUMBNAIL" ]; then
  echo "Either a message or at least one embed field must be provided."
  exit 1
fi

JSON_PAYLOAD=$(jq -n \
  --arg content "$MESSAGE" \
  --arg title "$EMBED_TITLE" \
  --arg description "$EMBED_DESCRIPTION" \
  --arg url "$EMBED_URL" \
  --arg color "$EMBED_COLOR" \
  --arg footer "$EMBED_FOOTER" \
  --arg image "$EMBED_IMAGE" \
  --arg thumbnail "$EMBED_THUMBNAIL" \
  '{
    content: $content,
    embeds: (
      if $title or $description or $url or $color or $footer or $image or $thumbnail then
        [
          {
            title: $title,
            description: $description,
            url: $url,
            color: ($color | tonumber),
            footer: { text: $footer },
            image: { url: $image },
            thumbnail: { url: $thumbnail }
          }
        ]
      else
        []
      end
    )
  }')

curl -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "$WEBHOOK_URL"