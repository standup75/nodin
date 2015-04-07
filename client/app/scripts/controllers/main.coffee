'use strict'
angular.module('nodinApp').controller 'MainCtrl', ($scope, $location, Session) ->
	$scope.user = Session.currentUser()
	$scope.logout = ->
		Session.logout()
		$location.path "/"
