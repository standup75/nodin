"use strict"
angular.module("nodeinApp").controller "AdminCtrl", ["$scope", "User", ($scope, User) ->
	$scope.pageSize = 40
	$scope.pageNumber = 0
	$scope.count = User.count()
	$scope.users = User.query
			limit: $scope.pageSize
			offset: 0
	$scope.remove = (user) ->
		if confirm("Do you really want to remove the user #{user.username} and all its data?")
			User.delete {username: user.username}, ->
				$scope.count.value--
				user.deleted = true
	$scope.predicate = 'username'
	$scope.reverse = false
	$scope.selectedCls = (predicate) ->
		if $scope.predicate is predicate
			if $scope.reverse then "icon-chevron-up" else "icon-chevron-down"
		else
			""
	$scope.changeSorting = (predicate) ->
		if $scope.predicate is predicate
			$scope.reverse = !$scope.reverse
		else
			$scope.predicate = predicate
			$scope.reverse = false
	$scope.gotoPage = (pageNumber) ->
		$scope.users = User.query 
			limit: $scope.pageSize
			offset: pageNumber * $scope.pageSize
		$scope.pageNumber = pageNumber
	$scope.lastPageNumber = -> (Math.ceil $scope.count.value / $scope.pageSize) - 1
]
