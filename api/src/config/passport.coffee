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
		done null, user

	passport.deserializeUser (user, done) ->
		User.findById user.id, (err, user) -> done err, user

