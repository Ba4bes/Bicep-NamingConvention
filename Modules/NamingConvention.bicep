@maxLength(8)
param teamName string
param function string
@allowed([
  'development'
  'test'
  'acceptance'
  'production'
])
param environment string
param index int

var functionShort = length(function) > 5 ? substring(function,0,5) : function
var teamNameShort = length(teamName) > 5 ? substring(teamName,0,5) : teamName
var environmentLetter = substring(environment,0,1)

var resourceNamePlaceHolder = '${teamName}-${environmentLetter}-${function}-[PH]-${padLeft(index,2,'0')}'
var resourceNameShortPlaceHolder = '${teamName}-${environmentLetter}-${functionShort}-[PH]-${padLeft(index,2,'0')}'

var storageAccountNamePlaceHolder = '${teamName}${environmentLetter}${functionShort}sta${padLeft(index,2,'0')}'
var vmNamePlaceHolder = '${teamNameShort}-${environmentLetter}-${functionShort}-${padLeft(index,2,'0')}'


output resourceName string = resourceNamePlaceHolder 
output resourceNameShort string = resourceNameShortPlaceHolder

output storageAccountName string = storageAccountNamePlaceHolder
output vmName string = vmNamePlaceHolder 
