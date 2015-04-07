'use strict'
angular.module('nodinApp').controller 'SignupCtrl', ($scope, $location, Session, User) ->
	$scope.user = 
		email: ""
		password: ""
	$scope.passwordConfirm = ""
	$scope.submit = (form, formParams) ->
		if form.$valid
			sendForm formParams
			$scope.showErrors = false
		else
			$scope.showErrors = true
	sendForm = (user) ->
		User.save user, (user) ->
			Session.currentUser user
			$location.path "/"
		, (res) -> alert res
