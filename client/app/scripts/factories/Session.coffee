"use strict"
angular.module("nodinApp").factory "Session", (settings, $http) ->
	_currentUser = JSON.parse(localStorage.currentUser) if localStorage.currentUser

	logout = ->
		_currentUser = null
		delete localStorage.currentUser
		$http {withCredentials: true, method: "GET", url: settings.apiUrl + "/logout"}

	# We check if we're still logged in by pinging the server
	$http({withCredentials: true, method: "GET", url: settings.apiUrl + "/users/current"})
	.success((user) -> logout() if !user or user.email isnt _currentUser?.email)
	.error(-> logout())

	logout: logout 
	currentUser: (user) ->
		if user
			_currentUser = {} unless _currentUser
			_currentUser[key] = value for key, value of user
			localStorage.currentUser = JSON.stringify user
		_currentUser
	isCurrent: (user) -> _currentUser and user and _currentUser.username is user.username
	getCurrentUserCopy: ->
		user = {}
		user[key] = value for key, value of _currentUser
		user
