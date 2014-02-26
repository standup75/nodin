"use strict"
angular.module("nodeinApp", ["ngRoute", "ngResource", "ngTouch"])
.constant "settings",
	baseUrl: "http://localhost:9000"
	apiUrl: "http://localhost:3000/api/v1"
