exports.index = (req, res) ->
	res.json message: "Welcome to nodin API"

exports.login = (passport) ->
	(req, res, next) ->
		passport.authenticate("local", (err, user, info) ->
			return res.status(401).json(error: err || info?.message, field: info?.field)  if err or not user
			req.login user, (err) ->
				if err and Object.keys(err).length
					return res.status(500).json
						error: "Could not log you in"
						details: err
				if req.body.rememberme
					req.session.cookie.maxAge = 2419200000 # 4 weeks
				else
					req.session.cookie.expires = false
				res.status(201).json user: user
		) req, res, next

exports.logout = (req, res) ->
	req.logout()
	res.send 200
