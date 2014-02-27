User = require("../app/models/user")
LocalStrategy = require('passport-local').Strategy

module.exports = (passport) ->

	passport.use new LocalStrategy 
		usernameField: "email"
		passwordField: "password"
	, (email, password, done) ->
		User.findOne
			email: email
		, (err, user) ->
			return done(err)  if err
			unless user
				return done null, false,
					message: "Unknown email."
			user.isValidPassword password, done

	passport.serializeUser (user, done) ->
		console.log "Serializing user: #{JSON.stringify(user)}"
		done null, user.id

	passport.deserializeUser (id, done) ->
		console.log "Deserializing user: #{id}"
		User.findById id, (err, user) -> done err, user

