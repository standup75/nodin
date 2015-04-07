User = require("../models/user")

isRole = (role, req, res, next) ->
	user = req.user
	if user
		User.findOne {email: user.email}, (err, user) ->
			if user?.role is role or user?.role is "admin"
				next err, user
			else
				res.send 401
	else
		res.send 401

module.exports =
	isAdmin: (req, res, next) -> isRole "admin", req, res, next
	isEditor: (req, res, next) -> isRole "editor", req, res, next

