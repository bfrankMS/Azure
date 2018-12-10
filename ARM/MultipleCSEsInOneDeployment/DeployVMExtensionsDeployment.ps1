# Uses the new (Find-Module AZ.*) modules for Azure PowerShell
# Launches a new Azure Template Deployment that includes calling 2 Custom Script Extensions on 1 VM one after another
# uploads 2 CSEs to an Azure Blob storage before - so that CSE can download the files.

$resourceGroupName = 'DeplVMExtension'
$Location = 'North Europe' 

Login-AzAccount 

Select-AzSubscription -Subscription "Visual Studio Ultimate bei MSDN"

New-AzResourceGroup -Name $resourceGroupName -Location $location

$TemplateParameters = @{
    "adminUsername" = [string](Read-Host -Prompt "Enter the virtual machine admin username");
    "adminPassword" = [System.Security.SecureString](Read-Host -Prompt "vmadmin password please" -AsSecureString);
    "dnsLabelPrefix" = [string](Read-Host -Prompt "Enter the DNS label prefix");
}

#$psEditor.Workspace 

$CSEs = ""
$currentPath = ".........PAth To VM Extensions..........."
$CSEs = Get-ChildItem -Path $currentPath -Filter "CSE_*" | Sort-Object
$StorageAccountName = "CSEsa0815".ToLower()
$ContainerName = "CSEs".ToLower()
    #upload them to a place where the VMs can access it e.g. github, onedrive, or Azure blob storage ;-)
        #create storageaccount & container 
        New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $resourceGroupName -SkuName Standard_LRS -Location $Location -Kind BlobStorage -AccessTier Cool 
        Set-AzCurrentStorageAccount -Name $StorageAccountName -ResourceGroupName $resourceGroupName
        New-AzRmStorageContainer -PublicAccess Blob -Name $ContainerName -ResourceGroupName $resourceGroupName -StorageAccountName $StorageAccountName
        
        $container = Get-AzRmStorageContainer -ResourceGroupName $resourceGroupName -StorageAccountName $StorageAccountName -Name $ContainerName

        #<#upload CSEs to azure container

        $CSEsOnAzure = @()
        foreach ($CSE in $CSEs)
        {
           #Set-AzureStorageBlobContent -Container $ContainerName -File $($CSE.FullName) -Force
           Set-AzStorageBlobContent -Container $ContainerName -File $($CSE.FullName) -Force
           $CSEsOnAzure += "https://$StorageAccountName.blob.core.windows.net/$ContainerName/" + $CSE.Name
        }

        #make sure CSEs are ordered
        $CSEsOnAzure = $CSEsOnAzure | Sort-Object 
#endregion  

$CSEsOnAzure

New-AzResourceGroupDeployment `
 -TemplateFile ".......path to .........\DeployVMExtensions.json" `
 -TemplateParameterObject $TemplateParameters `
 -ResourceGroupName $resourceGroupName #-Debug -Verbose

 Remove-AzVMCustomScriptExtension -ResourceGroupName $resourceGroupName -VMName 'SimpleWinVm' -Name 'CustomScriptExtension' -Debug -Verbose