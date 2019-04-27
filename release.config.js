module.exports = {
	release: {
		branch: 'master',
	},
	plugins: [
		'@semantic-release/commit-analyzer',
		'@semantic-release/release-notes-generator',
		["@semantic-release/exec", {
			"prepareCmd": "./update-version-number.sh ${nextRelease.version} && ./build.sh",
		}],
		["@semantic-release/github", {
			"assets": [
				{"path": "mgemod.zip", "label": "mgemod.zip"}
			]
		}]
	]
};
