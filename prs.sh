query="$(echo $1)"
curl -H 'Content-Type: application/json' \
   -H "Authorization: bearer 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" \
   -X POST -d "{ \"query\": \"$query\"}" https://api.github.com/graphql
