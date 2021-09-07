#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'json'
require 'fileutils'


GITHUB_TOKEN = ENV["GITHUB_TOKEN"] 

if !GITHUB_TOKEN
  puts "Please set GITHUB_TOKEN environment variable"
  exit 1
end

QUERY = ENV["GITHUB_PR_GRAPHQL_QUERY"] || %{{
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
    }
  }
}}

def display_and_exit(err)
	alfred_item = {
		"title" => err
	}
	res = { items: [alfred_item] }.to_json
	puts res
	Process.exit(0)
end

def fetch_prs_from_http
	response = Net::HTTP.post URI("https://api.github.com/graphql"),
	{ "query" => QUERY}.to_json,
	'Authorization' => "bearer #{GITHUB_TOKEN}",
	"Content-Type" => "application/json"

	responseJSON = JSON.parse(response.body)
	if response.code != "200"
		display_and_exit("Cannot fetch GitHub: #{response.code}")
	end
	prs = responseJSON.dig("data", "viewer", "pullRequests", "nodes")
	prs
end

BUNDLE_ID       = ENV['alfred_workflow_bundleid'] || "com.matv.githubpr" 
CACHE_DIR       = ENV['alfred_workflow_cache']    || "/tmp/#{BUNDLE_ID}"

FileUtils.mkdir_p(CACHE_DIR)

CACHE_FILE = "#{CACHE_DIR}/prs-cache.json"
CACHE_TIME = 60 * 5 # cache for 5 minutes
VERSION = 1

def get_prs
	if File.file?(CACHE_FILE)
		cached = JSON.parse(File.read(CACHE_FILE))
		if cached["v"] && cached["v"] === VERSION
			if (Time.now.to_i - cached["updated"].to_i) < CACHE_TIME
				prs = cached["prs"]
				return prs unless prs.nil?
			end
		end
	end
	prs = fetch_prs_from_http

	cache_contents = {"v": VERSION, "updated" => Time.now().to_i, "prs" => prs}
	File.write(CACHE_FILE, cache_contents.to_json)

	prs
end

def pr_to_alfred_items(prs)
	alfred_items = prs.map do |pr|
		{
			"title" => pr["title"],
			"url" => pr["url"],
			"subtitle" => pr["url"],
			"arg" => pr["url"]
		}
	end
	if alfred_items.empty?
		display_and_exit("No PRs found")
	end

	{ items: alfred_items }.to_json
end

prs = get_prs
output = pr_to_alfred_items(prs)



puts output