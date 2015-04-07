mongoose = require "mongoose"
base = require "./base"

postSchema = new mongoose.Schema
	title: type: String
	body: type: String
	createdAt: Date
	updatedAt: Date

postSchema.pre "save", (next) ->
	unless @createdAt
		@createdAt = @updatedAt = new Date
	else
		@updatedAt = new Date
	next()

postSchema.statics.publicFields = [ "title", "body", "createdAt", "updatedAt" ]
postSchema.statics.names =
	singular: "post"
	plural: "posts"

module.exports = base postSchema