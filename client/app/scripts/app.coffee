'use strict'

angular.module('nodinApp', [
  'ngResource'
  'ngRoute'
]).config ($httpProvider, $routeProvider) ->
  $httpProvider.defaults.withCredentials = true;
  $routeProvider.when('/',
    templateUrl: 'views/main.html'
    controller: 'MainCtrl').when('/login',
    templateUrl: 'views/login.html'
    controller: 'LoginCtrl').when('/signup',
    templateUrl: 'views/signup.html'
    controller: 'SignupCtrl').otherwise redirectTo: '/'
.constant "settings",
  baseUrl: "http://localhost:9000"
  apiUrl: "http://localhost:3000/api/v1"

