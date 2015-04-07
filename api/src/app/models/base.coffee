_ = require "lodash"
mongoose = require "mongoose"

module.exports = (schema, methods, statics) ->
	schemaName = schema.statics.names.plural
	console.log "initializing model '#{schemaName}'"
	schema.methods.assign = (model) ->
		for field in schema.statics.publicFields
			@[field] = model[field]  if model[field] isnt `undefined`
		@

	# based on http://mongoosejs.com/docs/api.html#document_Document-toObject
	schema.options.toJSON = {}  unless schema.options.toJSON
	
	schema.options.toJSON.transform = (doc, ret, options) ->
		jsonRepresentation =
			id: ret._id
		jsonRepresentation[field] = ret[field]  for field in schema.statics.publicFields
		jsonRepresentation

	_.assign(schema.methods, methods)  if methods	
	_.assign(schema.statics, statics)  if statics	

	mongoose.model schemaName, schema