_ = require("lodash")
User = require("../../models/user")
config = require("../../../config/config")
session = require("../session")
utils = require("../../utils/utils")

getUser = (user, res, callback) ->
	User.findOne
		email: user
	, (err, user) ->
		if err
			res.status(500).json error: "Something wrong happened while retrieving user '#{req.params.user}'"
		else
			if user
				callback user		
			else
				res.status(404)

checkUniquenessOf = (field, value, oldValue, callback) ->
	utils.checkUniquenessOf User, field, value, oldValue, callback

checkForPasswordUpdate = (req, callback) ->
	user = req.user
	newUser = req.body
	return callback() unless newUser.password and newUser.newPassword
	req.login {email: user.email, password: newUser.password}, (err) ->
		if err
			res.status(401).json error: "Wrong password"
		else
			utils.hash newUser.newPassword, (err, salt, hash) ->
				user.hash = hash
				user.salt = salt
				user.save (err) ->
					if err
						res.status(401).json error: "Could not update the password"
					else
						callback()

module.exports =
	options:
		before:
			index: session.isAdmin
			count: session.isAdmin
			destroy: session.isAdmin

	index: (req, res) ->
		limit = Math.min config.maxPerPage, req.query.limit or config.perPage
		offset = req.query.offset || 0
		find = {}
		_.assign(find, JSON.parse(req.query.find.replace("__", "$"))) if req.query.find
		sort = JSON.parse(req.query.sort.replace("__", "$")) if req.query.sort
		sort ||= { createdAt: -1 }
		User.find(find).sort(sort).limit(limit).skip(offset).exec (err, users) ->
			if err
				res.send 500
			else
				res.status(200).json users


	create: (req, res) ->

		findUserByEmail = (err, count) ->
			if count is 0
				User.signup req.body.email, req.body.password, (err, user) ->
					if err
						return res.status(500).json(
							error: "Sorry, could not sign up"
							details: err
						)
					req.login user, (err) ->
						if err and Object.keys(err).length
							return res.status(500).json(
								error: "Could not log in with the new user"
								details: err
							)
						res.status(201).json user
			else
				res.status(400).json
					error: "A user with this email address already exists"
					fields: "email"
					details: err


		if typeof req.body.email is "string" and typeof req.body.password is "string"
			User.count
				email: req.body.email
			, findUserByEmail
		else
			res.status(500).json error: "Wrong parameters"

	show: (req, res) ->
		getUser req.params.user, res, (user) ->
			res.status(200).json user

	update: (req, res) ->
		user = req.user
		return res.send(401) unless user and user.id is req.body.id
		checkForPasswordUpdate req, (err) ->
			if err
				res.status(401).json error: err
			else
				newUser = _.pick req.body, User.publicFields
				checkUniquenessOf "email", newUser.email, user.email, (err) ->
					if err
						res.status(401).json error: err
					else
						_.assign(user, newUser)
						user.save (err) ->
							if err
								res.send(500)
							else
								res.status(200).json user

	destroy: (req, res) ->
		if req.params.user
			User.findOne { email: req.params.email }, (err, user) ->
				if err
					res.status(401).json error: err
				else
					user.remove()
					res.send 201
		else
			res.send 500

	# non-rest routes

	count: (req, res) ->
		User.count().exec (err, count) ->
			if err
				res.status 500
			else
				res.status(200).json value: count

	current: (req, res) ->
		user = req.user
		response = if user then user else { message: "not logged in" }
		res.status(200).json response
