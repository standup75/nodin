angular.module("nodeinApp").directive "nodeinSameAs", ->
		require: 'ngModel'
		link: (scope, element, attributes, ctrl) ->
			ref = eval "scope.#{attributes.nodeinSameAs}"
			unless ref
				throw "Unknown scope value for #{attributes.nodeinSameAs}"
			ctrl.$parsers.unshift (viewValue) ->
				if ref.$viewValue is viewValue
					ctrl.$setValidity 'same', true
					viewValue
				else
					ctrl.$setValidity 'same', false
					`undefined`
