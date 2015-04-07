_ = require "lodash"
async = require "async"
User = require("../../models/user")
config = require("../../../config/config")
session = require("../session")
utils = require("../../utils/utils")
sendgrid  = require('sendgrid') process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD

getUserById = (id, res, callback) ->
	getUser {_id: id}, res, callback

getUserByEmail = (user, res, callback) -> getUser {email: user}, res, callback

getUser = (query, res, callback) ->
	User.findOne query, (err, user) ->
		if err
			res.status(500).json
				error: "Something wrong happened while retrieving user '#{user}'"
				details: err || ""
		else
			if user
				callback user		
			else
				res.send(404)

getUserIfNotCurrent = (user, userId, res, callback) ->
	if user.id is userId
		callback user
	else
		getUserById userId, res, callback

checkUniquenessOf = (field, value, oldValue, callback) ->
	utils.checkUniquenessOf User, field, value, oldValue, callback

checkForPasswordUpdate = (newUser, req, res, callback) ->
	return callback() unless req.body.password and req.body.newPassword
	newUser.isValidPassword req.body.password, (err, user, info) ->
		if err
			res.send 500
		else if user
			utils.hash req.body.newPassword, (err, salt, hash) ->
				user.hash = hash
				user.salt = salt
				user.needPasswordUpdate = false
				user.save (err) ->
					if err
						res.status(401).json error: "Could not update the password"
					else
						callback()
		else
			res.status(401).json error: "Wrong password"

module.exports =
	options:
		before:
			index: session.isEditor
			count: session.isAdmin
			destroy: session.isAdmin

	index: (req, res) ->
		limit = Math.min config.maxPerPage, req.query.limit or config.perPage
		offset = req.query.offset || 0
		if req.query.like
			like = new RegExp "^#{req.query.like}", "i"
			find = 
				$or: [
					email: like
				,
					name: like
				]
			sort = { email: 1 }
		else
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
							details: err || ""
						)

					req.login user, (err) ->
						if err and Object.keys(err).length
							return res.status(500).json
								error: "Could not log in with the new user"
								details: err || ""
						res.status(201).json user
			else
				res.status(400).json
					error: "A user with this email address already exists"
					field: "email"
					details: err || ""


		if typeof req.body.email is "string" and typeof req.body.password is "string"
			User.count
				email: req.body.email
			, findUserByEmail
		else
			res.status(500).json error: "Wrong parameters"

	show: (req, res) ->
		getUserByEmail req.params.user, res, (user) ->
			res.status(200).json user

	update: (req, res) ->
		return res.send(401)  unless req.user and (req.user.id is req.params.user or req.user.role in ["admin", "editor"])
		getUserIfNotCurrent req.user, req.params.user, res, (user) ->
			updateOtherFields = (newUser) ->
				delete newUser.featured # use setFeatured/removeFeatured to change the user's featured status
				_.assign(user, newUser)
				user.save (err) ->
					if err
						res.status(500).json details: err || ""
					else
						res.status(201).json user
			checkEmailAndUpdate = (newUser) ->
				if newUser.email
					checkUniquenessOf "email", newUser.email, user.email, (err) ->
						if err
							res.status(401).json details: err || ""
						else
							updateOtherFields newUser
				else
					updateOtherFields newUser
			checkForPasswordUpdate user, req, res, (err) ->
				if err
					res.status(401).json details: err || ""
				else
					newUser = _.pick req.body, User.publicFields
					if newUser.role
						session.isAdmin req, res, -> checkEmailAndUpdate newUser
					else if user.id is req.params.user
						checkEmailAndUpdate newUser
					else
						res.status(401).json
							error: "Not the right user"
				null


	destroy: (req, res) ->
		if req.params.user
			User.findOne { email: req.params.user }, (err, user) ->
				if err
					res.status(401).json details: err || ""
				else if !user
					res.send 200
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

	forgot: (req, res) ->
		userEmail = req.params.user
		return res.send(401).json({error: "No email address found"}) unless userEmail
		getUserByEmail userEmail, res, (user) ->
			newPwd = utils.randomString 5
			utils.hash newPwd, (err, salt, hash) ->
				user.hash = hash
				user.salt = salt
				user.needPasswordUpdate = true
				user.save (err) ->
					if err
						res.status(500).json error: "Could not update the password"
					else
						sendgrid.send
							to: user.email,
							from: "\"Nodin\"<admin@nodin.com>",
							subject: "Your new password",
							text: "You can now log in with #{newPwd}"
						, (err, json) ->
							if err
								console.log "password for #{user.email} is now #{newPwd}"
								res.status(500).json details: err || ""
							else
								res.send(201)
