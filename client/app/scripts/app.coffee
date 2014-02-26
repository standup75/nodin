"use strict"

angular.module("nodeinApp").config ($httpProvider, $routeProvider, $sceDelegateProvider) ->
	$httpProvider.defaults.withCredentials = true;
	$sceDelegateProvider.resourceUrlWhitelist ["self", "http://wavelinks-assets.s3.amazonaws.com/**"]
	$routeProvider.when("/",
		templateUrl: "views/home.html"
		name: "Home"
	).when("/admin",
		templateUrl: "views/admin.html"
		controller: "AdminCtrl"
		name: "Admin"
	).otherwise redirectTo: "/"
