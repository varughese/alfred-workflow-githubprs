// #!/usr/bin/env node

const http = require("https");

function httpRequest(params, postData) {
    return new Promise(function (resolve, reject) {
        var req = http.request(params, function (res) {
            // cumulate data
            var body = [];
            res.on("data", function (chunk) {
                body.push(chunk);
            });
            // resolve on end
            res.on("end", function () {
                try {
                    body = Buffer.concat(body).toString();
                } catch (e) {
                    reject(e);
                }
                resolve(body);
            });
        });
        // reject on request error
        req.on("error", function (err) {
            reject(err);
        });
        if (postData) {
            req.write(postData);
        }
        // IMPORTANT
        req.end();
    });
}

const query = `{
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
}`;

const GITHUB_TOKEN = "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";

const fetchPRs = async (args) => {
    const params = {
        host: "api.github.com",
        path: "/graphql",
        method: "POST",
        headers: {
            Authorization: `bearer ${GITHUB_TOKEN}`,
            "user-agent": "node.js",
            "Content-Type": "application/json",
        },
    };
    const body = JSON.stringify({ query });
    let results;
    try {
        const raw = await httpRequest(params, body);
        results = JSON.parse(raw).data.viewer.pullRequests.nodes;
    } catch (e) {
        console.error(e);
    }
    return results;
};

const run = async () => {
    const prs = await fetchPRs();
    console.log(prs);
};

// run();

console.log(
    JSON.stringify({
        items: [
            {
                title: "hello",
                url: "https://google.com",
                arg: "0,3",
                subtitle: "yo",
            },
        ],
    })
);
