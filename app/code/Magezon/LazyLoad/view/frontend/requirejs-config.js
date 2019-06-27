var config = {
    map: {
        "*": {
            lazyLoad: "Magezon_LazyLoad/js/lazy.min",
            lazyLoadPlugins: 'Magezon_LazyLoad/js/lazy.plugins.min'
        }
    },
    shim: {
        'lazyLoad': {
            'deps': ['jquery']
        },
        'lazyLoadPlugins': {
            'deps': ['jquery', 'lazyLoad']
        }
    }
};