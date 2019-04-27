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
				{"path": "addons/sourcemod/scripting/mgemod.smx", "label": "Compiled plugin"}
			],
			"successComment": false
		}]
	]
};
