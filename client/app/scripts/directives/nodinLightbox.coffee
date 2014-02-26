app = angular.module("nodeinApp")

app.controller "lightboxCtrl", ($timeout, $scope) ->
	$scope.display = 
		lightbox: "hide"
	$scope.options = {}
	$scope.close = ->
		unless $scope.display.lightbox is "hide"
			@removeServerError()
			$scope.$broadcast "close-modal", $scope.openedModal
			$scope.display.lightbox = "hide"
			$scope.display[$scope.openedModal] = "none"
	$scope.$on "open-modal", (e, name, options) ->
		$scope.display.lightbox = "animation-fadein #{name}"
		$scope.display[name] = "block"
		$scope.openedModal = name
		$scope.options[name] = options
	$scope.submit = (form, formParams) ->
		if @inputEls
			# hack from eliasdawson comment on https://github.com/angular/angular.js/issues/1460
			for inputEl in @inputEls
				angular.element(inputEl).controller( 'ngModel' ).$setViewValue( inputEl.value );

		@removeServerError()
		if form.$valid
			@sendForm formParams
			@showErrors = false
		else
			@showErrors = true
	$scope.removeServerError = ->
		$scope.serverError = null
		if @invalidField
			@["#{@name}Form"][@invalidField].$setValidity "server", true
			@invalidField = null
	$scope.showServerError = (res) ->
		if res.data.field
			$scope.serverError = res.data.error
			@invalidField = res.data.field
			@["#{@name}Form"][res.data.field].$setValidity "server", false
		else 
			$scope.serverError = "The server can't be reach. Are you online?"
	$scope.init = (name) ->
		@name = name
		$scope.display[name] = "none"
	# abstract method to be used by submit
	$scope.sendForm = (user) -> throw "Unimplemented abstract method: FormModalScope.sendForm"
	$scope.autofocus = ($input) ->
		@$on "open-modal", (e, name) =>
			if name is @name
				$timeout ->
					$input[0].focus()
	$scope.$on "$routeChangeStart", (event, next, current) -> $scope.close()

app.directive "nodinLoginModal", ($http, $location, Session, settings) ->
	restrict: "E"
	scope: true
	link: (scope, element) ->
		# needed for the hack in submit()
		scope.inputEls = element[0].querySelectorAll "[ng-model]"
		scope.init "login"
		scope.autofocus element.find("input")
		scope.sendForm = (user) ->
			$http.post(settings.apiUrl + "/login", user)
			.success (res) ->
				Session.currentUser res.user
				scope.close()
				alert "Welcome back #{res.user.email}!"
			.error (res) -> scope.showServerError
				data: res

app.directive "nodinSignupModal", ($location, User, Session) ->
	restrict: "E"
	scope: true
	link: (scope, element) ->
		# needed for the hack in submit()
		scope.inputEls = element[0].querySelectorAll "[ng-model]"
		scope.init "signup"
		scope.autofocus element.find("input")
		scope.sendForm = (user) ->
			User.save user, (user) ->
				Session.currentUser user
				scope.close()
			, (res) -> scope.showServerError res

app.directive "nodinSettings", ($rootScope, User, Session) ->
	restrict: "E"
	scope: true
	link: (scope, element) ->
		userCopy = null
		scope.init "settings"
		scope.autofocus element.find("input")

		scope.$on "open-modal", (e, name) ->
			if name is scope.name
				scope.user = Session.currentUser()
				userCopy = Session.getCurrentUserCopy()
		scope.sendForm = (user) ->
			User.update {id: user.id}, user, (user) ->
				Session.currentUser user
				scope.close()
				alert "Settings updated"
			, scope.showServerError
		scope.cancel = ->
			scope.close()
			Session.currentUser userCopy
		scope.ok = -> scope.submit scope.settingsForm, scope.user
