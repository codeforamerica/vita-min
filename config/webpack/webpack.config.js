const webpack = require('webpack')
const { generateWebpackConfig, merge } = require('shakapacker')
const webpackConfig = generateWebpackConfig()

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.

module.exports = merge(webpackConfig, {
    plugins: [
        new webpack.ProvidePlugin({
            $: 'jquery',
            jQuery: 'jquery',
        })
    ],
})
