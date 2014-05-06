_ = require("lodash")
config = require("../../config/config")
crypto = require("crypto")
len = 128

iterations = 12000

getRandomInt = (min, max) ->
	Math.floor(Math.random() * (max - min + 1)) + min

module.exports = 
	hash: (pwd, salt, fn) ->
		if 3 is arguments.length
			crypto.pbkdf2 pwd, salt, iterations, len, fn
		else
			fn = salt
			crypto.randomBytes len, (err, salt) ->
				return fn(err)  if err
				salt = salt.toString("base64")
				crypto.pbkdf2 pwd, salt, iterations, len, (err, hash) ->
					return fn(err)  if err
					fn null, salt, hash

	randomString: (len) ->
		buf = []
		chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
		charlen = chars.length
		i = 0

		while i < len
			buf.push chars[getRandomInt(0, charlen - 1)]
			++i
		buf.join ""

	generateUuid: ->
		d = new Date().getTime()
		"xxxxxxxx_xxxx_4xxx_yxxx_xxxxxxxxxxxx".replace /[xy]/g, (c) ->
			r = (d + Math.random() * 16) % 16 | 0
			d = Math.floor(d / 16)
			((if c is "x" then r else (r & 0x7 | 0x8))).toString 16

	# old value is optional
	checkUniquenessOf: (Model, field, value, oldValue, callback) ->
		unless callback?
			callback = oldValue
			oldValue = null
		if value
			if value is oldValue
				callback()
			else
				query = {}
				query[field] = value
				Model.count query, (err, count) ->
					err = "This #{field} already exists" if count > 0
					callback err
		else
			callback "no email specified"

