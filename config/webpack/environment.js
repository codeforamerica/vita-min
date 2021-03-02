const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const webpack = require('webpack');

environment.loaders.prepend('erb', erb)

environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        Rails: '@rails/ujs'
    })
)

environment.loaders.append('honeycrisp-js', {
    test: [
        /honeycrisp-gem/
    ],
        use: [
        {
            loader: 'imports-loader',
            options: {
                type: 'commonjs',
                imports: [
                    {
                        moduleName: 'jquery',
                        name: 'jQuery',
                    },
                    {
                        moduleName: 'jquery',
                        name: '$'
                    }
                ]
            }
        }
    ]
})

module.exports = environment
