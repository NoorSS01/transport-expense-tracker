// Learn more https://docs.expo.io/guides/customizing-metro
// Wrap require-based config in try/catch so this file is safe if accidentally loaded
// in a non-Node environment (some runtimes may attempt to evaluate project files).
try {
	const { getDefaultConfig } = require('expo/metro-config');

	const config = getDefaultConfig(__dirname);

	// Ensure proper handling of TypeScript/JavaScript files and include font asset extensions
	// Merge with defaults instead of overwriting so we don't drop important defaults.
	config.resolver.sourceExts = [...config.resolver.sourceExts, 'js', 'jsx', 'json', 'ts', 'tsx'];
	// Add font extensions so Metro can resolve .ttf/.otf used by vector icon packages
	config.resolver.assetExts = [
		...config.resolver.assetExts,
		'png',
		'jpg',
		'jpeg',
		'gif',
		'webp',
		'ttf',
		'otf'
	];

	module.exports = config;
} catch (e) {
	// Running in an environment without Node's require (e.g., client runtime).
	// Do nothing — exporting nothing prevents runtime ReferenceError for 'require'.
}