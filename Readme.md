# GRAND-IQ Powershell Module
A Powershell module for the F5 BIG-IQ REST API interface.

The goal is to provide easy access to any BIG-IQ REST API via the core `Invoke-BIGIQRestRequest` function. As well as offer wrappers around the core function to give you familiar access to higher level BIG-IQ functionality such as virtual servers, pools, etc.

## Why the name 'GRAND-IQ'?
I'm not affiliated with the F5 company. So I use 'GRAND' in place of 'BIG' for the module name alone. If F5 wants to release an offical Powershell module for the BIG-IQ in the future, I'm not in their way. The functions, cmdlets, etc still use 'BIGIQ' to make it clear what's being used though.

## Installing

```
Install-Module GRAND-IQ
Import-Module GRAND-IQ
```

## Logging in

```
$yourCredential = Get-Credential
$loginReference = 'https://loginreference link' # See note below.
New-BIGIQAuthenticationToken -rootUrl 'https://url-to-your-big-iq' -credential $yourCredential -loginReference $loginReference -setSession
```

The session is stored within the script module and is used automatically as long as you specify the `-setSession` switch. `New-BIGIQAuthenticationToken` outputs the session object and you can keep it in a variable for use later. This would be useful if you plan on querying multiple BIG-IQs within the same script.

> Get the login reference link by watching your network traffic when logging in via the web browser.

## Querying virtual servers example

```
# Must already be logged in via `New-BIGIQAuthenticationToken`
$result = Invoke-BIGIQRestRequest -path "/mgmt/tm/ltm/virtual"
$result.items
```

The above outputs the virtual servers currently available on your BIG-IQ:

```
kind                         : tm:ltm:virtual:virtualstate
name                         : foo-bar.mycorp.com_https
partition                    : Common
fullPath                     : /Common/foo-bar.mycorp.com_https
...
```

## Invoke-BIGIQRestRequest

This is the core function that provides familiar access to the BIG-IQ REST api. With very few exceptions (`New-BIGIQAuthenticationToken` for one) all wrapper functions will use this core function to communicate with the BIG-IQ. If you cannot find needed functionality in the wrapper functions (or it simply doesn't exist yet) you can use `Invoke-BIGIQRestRequest`. You will need to be familiar with the [BIG-IQ REST API](https://clouddocs.f5.com/products/big-iq/mgmt-api/v6.0/#) to do so.

Parameters
* path 
    - The path to the BIG-IQ resource being queried or updated.
    - The REST method to be used.
* requestParameters
    - The powershell object to send in the body of the request. This gets converted to JSON.
