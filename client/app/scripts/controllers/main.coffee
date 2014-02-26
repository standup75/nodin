"use strict"
angular.module("nodeinApp").controller "MainCtrl", ($scope, $location, Session) ->
	timer = null
	$scope.session = Session
	$scope.logout = ->
		Session.logout()
		alert "You've been logged out"
		$location.path "/"
	$scope.goToSettings = (evt) ->
		evt.preventDefault()
		$scope.$broadcast "open-modal", "settings"
