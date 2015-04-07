_ = require "lodash"
session = require "./session"
config = require "../../config/config"
async = require "async"

module.exports = (Model, extension) ->
	base =
		options:
			before:
				create: session.isEditor
				update: session.isEditor
				destroy: session.isEditor

		index: (req, res) ->
			find = {}
			_.assign(find, Model.defaultQuery)  if Model.defaultQuery
			_.assign(find, JSON.parse(req.query.find.replace("__", "$")))  if req.query.find
			sort = JSON.parse(req.query.sort.replace("__", "$"))  if req.query.sort
			unless sort
				if Model.defaultSort
					sort = Model.defaultSort
				else if "priority" in Model.publicFields
					if "name" in Model.publicFields
						sort = { priority: -1, name: 1 }
					else
						sort = { priority: -1 }
				else
					sort = { createdAt: -1 }
			Model.find(find).sort(sort).exec (err, models) ->
				if err
					res.status(500).json
						error: "Could not list the #{Model.names.plural}"
						details: err || ""
				else
					res.status(200).json models

		create: (req, res) ->
			new Model().assign(req.body).save (err, model) ->
				if err
					res.status(500).json
						error: "Could not create the #{Model.names.singular} #{req.body.name || ""}"
						details: err || ""
				else
					res.status(201).json model

		show: (req, res) ->
			selector = {}
			selector[Model.publicFields[0]] = req.params[Model.names.singular]
			Model.findOne selector, (err, model) ->
				if err or not model
					res.status(400).json
						error: "Could not find the #{Model.names.singular} with #{Model.publicFields[0]} = #{req.params[Model.names.singular]}"
						details: err || ""
				else
					res.status(200).json model

		update: (req, res) ->
			modelName = Model.names.singular
			Model.findOne { _id: req.params[modelName] }, (err, model) ->
				if err or not model
					res.status(500).json
						error: "Could not find the #{modelName} with id = #{req.params[modelName]}"
						details: err || ""
				else
					async.series [
						(callback) ->
							return callback()  unless model.preUpdate
							model.preUpdate req.body, callback
						(callback) -> 
							model.assign(req.body).save callback
					], (err, results) ->
						if err
							res.status(500).json
								error: "Could not save the updated #{modelName} with id = #{req.params[modelName]}"
								details: err || ""
						else
							res.status(201).json results[results.length - 1][0]

		destroy: (req, res) ->
			modelName = Model.names.singular
			Model.findOne { _id: req.params[modelName] }, (err, model) ->
				if err or not model
					res.status(500).json
						error: "Could not delete the #{modelName} with id = #{req.params[modelName]}"
						details: err || ""
				else
					model.assign(req.body).remove (err, results) ->
						if err
							res.status(500).json
								error: "Could not delete #{modelName} with id = #{req.params[modelName]}"
								details: err || ""
						else
							res.send 201

	_.merge(base, extension)  if extension

	base