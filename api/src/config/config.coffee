module.exports = do ->
	config =
		global:
			perPage: 3
			maxPerPage: 100
			session:
				db: "sessions"
				secret: "n0d1n_sEcret"

		development:
			origin: "http://localhost:9000"
			db: "mongodb://localhost/nodin"
			app:
				name: "nodin Dev"

		production:
			origin: "TBD"
			db: process.env.MONGOLAB_URI
			app:
				name: "nodin"

	settings = config.global
	envSettings = config[process.env.NODE_ENV or "development"]
	settings[key] = envSettings[key] for key of envSettings

	settings
