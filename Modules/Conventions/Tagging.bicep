param Owner string
param CostCenter string

@allowed([
  'development'
  'test'
  'acceptance'
  'production'
])
param environment string

param DeploymentDate string = utcNow('yyyy-MM-dd')

var tagsObject = {
  'Owner': Owner
  'CostCenter': CostCenter
  'Environment': environment
  'DeploymentDate': DeploymentDate
}

output Tags object = tagsObject
