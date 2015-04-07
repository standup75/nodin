module.exports = do ->
	config =
		global:
			session:
				db: "sessions"
				secret: "n0d1N_sEcret"

		development:
			origins: ["http://localhost:9000", "http://localhost:9100"]
			db: "mongodb://localhost/nodin"
			app:
				name: "nodin dev"

		production:
			origins: ["http://localhost:9000", "http://localhost:9100"]
			db: process.env.MONGOLAB_URI
			app:
				name: "nodin"

	settings = config.global
	env = process.env.NODE_ENV or "development"
	settings.env = env
	env = "production"  if env is "test"
	settings[key] = value for key, value of config[env]

	settings