angular.module("app").controller "AccountsController", ($scope, $location, RpcService, Shared, Growl) ->
    $scope.new_address_label = ""
    $scope.addresses = []
    $scope.pk_label = ""
    $scope.pk_value = ""
    $scope.wallet_file = ""
    $scope.wallet_password = ""
    non0addr={}
    Shared.trxFor=""
  
    $scope.accountClicked = (name, address, active_key)->
        Shared.accountName  = name
        Shared.accountAddress = address
        Shared.trxFor = name
        Shared.active_key = active_key


    #TODO ADD a Barrier or something to deal with race condition
    refresh_addresses = ->
        RpcService.request('wallet_account_balance').then (response) ->
            console.log(response.result)
            non0addr={}
            #$scope.addresses.splice(0, $scope.addresses.length)
            angular.forEach response.result, (val) ->
                non0addr[val[0]]=val[1]
                #$scope.addresses.push({name: val[0], balance: val[1]})
    refresh_addresses()


    refresh_more_addresses = ->
        RpcService.request('wallet_list_receive_accounts').then (response) ->
            $scope.addresses.splice(0, $scope.addresses.length)
            console.log response.result
            angular.forEach response.result, (val) ->
                active_key = val.active_key_history[val.active_key_history.length - 1][1]
                $scope.addresses.push({name: val.name, balance:  non0addr[val.name],  adress: val.address, active_key: active_key, regdat: val.registration_date})
    refresh_more_addresses()

    $scope.create_address = ->
        RpcService.request('wallet_create_account', [$scope.new_address_label]).then (response) ->
            $scope.new_address_label = ""
             refresh_addresses()
