define ['angular', 'angular-route', 'angular-cookies', 'angular-animate', 'angular-ui-bootstrap-tpls',
        'angular-headroom', 'local',
        'controller', 'service', 'resource', 'filter', 'directive'],
->
  'use strict'
  angular.module('app',
    ['ngRoute', 'ngCookies', 'ngAnimate' , 'ui.bootstrap', 'headroom', 'local', 'controller', 'service', 'resource',
     'filter', 'directive'])

  #config app
  .constant 'CONFIG',
    'resource':
      'image': '/image'
      'javascript': '/javascript'
      'style': '/style'
    'message':
      'errors.route.changeError': 'Route change error'
      'errors.route.401Error': 'Not authorized'
      'errors.route.403Error': 'Not allow access'
      'errors.route.404Error': 'Not fount'
      'errors.route.500Error': 'Server error'
      'errors.route.unknownError': 'Unknown error'
      'errors.browser.ieSupportError': 'Not support the Internet explorer browser version below 8'

  .config ($routeProvider, $locationProvider, $httpProvider) ->
    #use the HTML5 History API
    $locationProvider.html5Mode(true)

    #$resourceProvider.defaults.stripTrailingSlashes = false
    $httpProvider.defaults.headers.common =
      'x-Requested-With': 'XMLHttpRequest'

    contentType = 'application/x-www-form-urlencoded;charset=utf-8'
    #Use x-www-form-urlencoded Content-Type
    $httpProvider.defaults.headers.post['Content-Type'] = contentType
    $httpProvider.defaults.headers.put['Content-Type'] = contentType
    $httpProvider.defaults.transformRequest = (data)->
      if data
        $.param(data)

    #异常过滤
    $httpProvider.interceptors.push ($q, $location, Message, Alert)->
      responseError: (response) ->
        switch response.status
          when 401 then $location.path('/signin')
          when 403 then Alert.addAlert({type: 'danger', msg: 403 + " - " + Message.get('message',
            'errors.route.403Error')})
          when 404 then Alert.addAlert({type: 'danger', msg: 404 + " - " + Message.get('message',
            'errors.route.404Error')})
          when 500 then Alert.addAlert({type: 'danger', msg: 500 + " - " + Message.get('message',
            'errors.route.500Error')})
          else
            Alert.addAlert({type: 'danger', msg: "Error - " + Message.get('message', 'errors.route.unknownError')})

        $q.reject(response)


    #    $routeProvider
    #    .when '/',
    #      templateUrl: 'view/app/home.html', controller: 'HomeCtrl'
    #    .when '/signup',
    #      templateUrl: 'view/app/signup.html', controller: 'SignupCtrl'
    #    .when '/signin',
    #      templateUrl: 'view/app/signin.html', controller: 'SigninCtrl'
    #    .when '/about',
    #      templateUrl: 'view/app/about.html', controller: 'AboutCtrl'
    #    .when '/calendar',
    #      templateUrl: 'view/app/schedule/calendar.html', controller: 'CalendarCtrl'
    #    .otherwise
    #        redirectTo: '/'
    resolver = (requires)->
      resolver: ($q, $rootScope)->
        defer = $q.defer()
        require requires, ->
          $rootScope.$apply ->
            defer.resolve()
        defer.promise

    router =
      default: '/'
      other:
        '/':
          templateUrl: 'view/app/home.html',controller: 'HomeCtrl'

        '/about':
          templateUrl: 'view/app/about.html',controller: 'AboutCtrl'

        '/calendar':
          templateUrl: 'view/app/schedule/calendar.html',controller: 'CalendarCtrl',requires: ['javascript/controller/schedule']


    if router.other
      angular.forEach(router.other, (conf, path)->
        if !conf.requires
          $routeProvider
          .when path,
            templateUrl: conf.templateUrl, controller: conf.controller
        else
          $routeProvider
          .when path,
            templateUrl: conf.templateUrl, controller: conf.controller, resolve: resolver(conf.requires)
      )
    if router.default
      $routeProvider.otherwise
        redirectTo: router.default

  .run ($rootScope, $location, Message, Alert) ->
    $rootScope.path = $location.path();
    $rootScope.$on('$routeChangeStart', (newVal) ->
      console.log newVal
    )

    $rootScope.$on('$routeChangeSuccess', (newVal) ->
      $('html, body').animate({scrollTop: '0px'}, 400, 'linear')
      $rootScope.path = $location.path()
    )

    $rootScope.$on('$routeChangeError', (newVal) ->
      Alert.addAlert({type: 'danger', msg: "Error - " + Message.get('message', 'errors.route.changeError')})
    )
