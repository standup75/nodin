User = require("../models/user")

module.exports =
	isAdmin: (req, res, next) ->
		user = req.user
		if user
			User.findOne {email: user.email}, (err, user) ->
				if user?.role is "admin"
					next()
				else
					res.send 401
		else
			res.send 401


