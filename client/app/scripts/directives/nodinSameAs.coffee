angular.module("nodinApp").directive "nodinSameAs", ->
		require: 'ngModel'
		link: (scope, element, attributes, ctrl) ->
			ref = eval "scope.#{attributes.nodinSameAs}"
			unless ref
				throw "Unknown scope value for #{attributes.nodinSameAs}"
			ctrl.$parsers.unshift (viewValue) ->
				if ref.$viewValue is viewValue
					ctrl.$setValidity 'same', true
					viewValue
				else
					ctrl.$setValidity 'same', false
					`undefined`
