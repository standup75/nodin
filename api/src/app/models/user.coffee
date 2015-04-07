_ = require "lodash"
mongoose = require "mongoose"
utils = require "../utils/utils"
base = require "./base"

userSchema = new mongoose.Schema
	createdAt: Date
	updatedAt: Date
	email: { type: String, required: true, unique: true }
	salt: String
	role: String
	hash: String
	name: String
	url: String
	needPasswordUpdate: Boolean

userSchema.statics.signup = (email, password, done) ->
	User = this
	utils.hash password, (err, salt, hash) ->
		return done(err) if err
		User.create
			email: email
			salt: salt
			hash: hash
		, (err, user) -> done err, user

userSchema.methods.isValidPassword = (password, done) ->
	utils.hash password, @salt, (err, hash) =>
		return done(err) if err
		return done(null, @) if hash.toString() is @hash
		done null, false,
			message: "Incorrect password"
			field: "password"

userSchema.pre "save", (next) ->
	unless @createdAt
		@createdAt = @updatedAt = new Date
	else
		@updatedAt = new Date
	next()

userSchema.statics.publicFields = [ "email", "role", "name", "url", "needPasswordUpdate" ]
userSchema.statics.names =
	singular: "user"
	plural: "users"

module.exports = base userSchema