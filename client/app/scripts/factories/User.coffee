"use strict"
angular.module("nodinApp").factory "User", (settings, $resource) ->
	escapedBaseUrl = settings.apiUrl.replace /(http:\/\/[^\/]*):/, "$1\\:" # escape the port
	$resource "#{escapedBaseUrl}/users/:email/:action/:option", { email: "@email", option: "@option" },
		count: 
			method: "GET"
			params: { action: "count" }
			withCredentials: true
		query:
			method:'GET'
			isArray:true
			withCredentials: true
		delete:
			method:'DELETE'
			withCredentials: true
		update:
			method:'PUT'
			withCredentials: true
		# need to remove the default email param so that the route does not contain it
		save:
			method:'POST'
			params: { email: "" }
