import sys
from workflow import Workflow, web

TOKEN = "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"

query = """
{
  viewer {
    pullRequests(first: 100, states: OPEN) {
      totalCount
      nodes {
        createdAt
        number
        title
        url
        updatedAt
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
"""

def main(wf):
    url = 'https://api.github.com/graphql'
    params= dict(auth_token=TOKEN, query=query, format="json")
    r = web.get(url, params)

    result = r.json()
    print(result)

if __name__ == u"__main__":
    wf = Workflow()
    sys.exit(wf.run(main))