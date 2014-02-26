_ = require("lodash")
mongoose = require("mongoose")
utils = require("../utils/utils")

userSchema = new mongoose.Schema
	createdAt: Date
	updatedAt: Date
	email: String
	salt: String
	role: String
	hash: String
	rememberMeToken: String

userSchema.statics.publicFields = [ "email" ]

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

# based on http://mongoosejs.com/docs/api.html#document_Document-toObject
userSchema.options.toJSON = {}  unless userSchema.options.toJSON
userSchema.options.toJSON.transform = (doc, ret, options) ->
	email: ret.email
	id: ret._id

User = mongoose.model("User", userSchema)
module.exports = User