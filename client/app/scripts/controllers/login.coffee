'use strict'
angular.module('nodinApp').controller 'LoginCtrl', ($scope, $http, $location, Session, settings) ->
	$scope.submit = (form, formParams) ->
		if form.$valid
			sendForm formParams
			$scope.showErrors = false
		else
			$scope.showErrors = true
	sendForm = (user) ->
		$http.post(settings.apiUrl + "/login", user)
		.success (res) ->
			Session.currentUser res
			$location.path "/"
		.error (res) -> alert res
