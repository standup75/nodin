require "express-namespace"
require "express-mongoose"
require "express-resource-new"
express = require("express")
mongoose = require("mongoose")
config = require("./config/config")

mongoose.connect config.db
mongoose.connection.on "connected", ->
	console.log "Mongoose default connection open to " + config.db
mongoose.connection.on "error", (err) ->
	console.log "Mongoose default connection error: " + err
mongoose.connection.on "disconnected", ->
	console.log "Mongoose default connection disconnected"
process.on "SIGINT", ->
	mongoose.connection.close ->
		console.log "Mongoose default connection disconnected through app termination"
		process.exit 0

MongoStore = require('connect-mongo') express
app = express()
fs = require("fs")
passport = require("passport")

allowCrossDomain = (req, res, next) ->
	res.header "Access-Control-Allow-Origin", config.origin
	res.header "Access-Control-Allow-Credentials", "true"
	res.header "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,OPTIONS"
	res.header "Access-Control-Allow-Headers", "Content-Type"
	next()

models_dir = __dirname + "/app/models"

app.configure ->
	app.set "port", process.env.PORT or 3000
	app.use express.logger("dev")
	app.use express.cookieParser("badaboum")
	app.use express.bodyParser()
	app.use express.session
		store: new MongoStore
			url: config.db
			db: config.session.db
		secret: config.session.secret
	app.use passport.initialize()
	app.use passport.session()
	app.use express.methodOverride()
	app.use allowCrossDomain
	app.use app.router
	app.set "controllers", __dirname + "/app/controllers"

app.configure "development", ->
	app.use express.errorHandler()

app.use (err, req, res, next) ->
	res.status(err.status or 500).json error: err

app.use (req, res, next) ->
	res.status(404).json error: "Not found"

require("./config/passport") passport
require("./config/routes") app, passport

# start
app.listen app.get("port"), ->
	console.log "nodin API listening on port " + app.get("port") + ", running in " + app.settings.env + " mode, Node version is: " + process.version
	#show all the routes that express-resource creates for you.
	#console.log app.routes
