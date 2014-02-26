controllers = require("../app/controllers")

module.exports = (app, passport) ->
	
	# router
	app.get "/", controllers.index
	app.namespace "/api/v1", ->
		app.post "/login", controllers.login(passport)
		app.get "/logout", controllers.logout
		app.resource "users", ->
			@collection.get "count"
			@collection.get "current"
		app.options "*", (req, res, next) -> res.send 200

