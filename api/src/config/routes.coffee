mainController = require "../app/controllers"
usersController = require "../app/controllers/users"

module.exports = (app, passport) ->
	
	# router
	app.get "/", mainController.index
	app.namespace "/api/v1", ->
		app.post "/login", mainController.login(passport)
		app.get "/logout", mainController.logout
		app.resource "posts"
		app.resource "users", ->
			@collection.get "count"
			@collection.get "current"
			@member.get "forgot"
		app.options "*", (req, res, next) -> res.send 200

