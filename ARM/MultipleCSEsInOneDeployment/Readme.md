**How to call 2 Custom Script Extensions for one VM in one template?**

you might have seen this:
<https://social.msdn.microsoft.com/Forums/en-US/283a2d33-0619-45f4-93dc-16375ab7e13d/deploying-multiple-instances-of-custom-script-extension-through-arm-templates>

which indicates it is not possible...

However I came accross <https://docs.microsoft.com/en-us/azure/architecture/building-blocks/extending-templates/update-resource>

"...There are some scenarios in which you **need to update a resource during a deployment**...you must **reference the resource once** in the template **to create it** and then **reference the resource** by the same name to **update it later**...if two resources have the **same name in a template**,... throws an **exception**. To **avoid this error**, specify the updated resource in a **second template** that's **either linked** or included as **a subtemplate** using the **Microsoft.Resources/deployments** resource type..."

Here is a sample of using a subtemplate "FirstCSE":
* **1 ARM Template** (_DeployVMExtensions.json_):
FirstCSE - calls the first custom script extension (after the VM has been created)
The second extension is called after 'FirstCSE' ("dependsOn": [            "FirstCSE"    ])
* **2 CSExtensions** (_01_CSE...,02_CSE..._) -> installiert und downloaded was in der VM
* **1 Powershell deployment file** (_Deploy....ps1_) -> lädt die CSEs in einen Block Blob hoch und started das ARM Deployment

![Deployment view in azure portal](https://github.com/bfrankMS/Azure/blob/master/ARM/MultipleCSEsInOneDeployment/DeployVMExtensions.PNG "Deployment view in azure portal")

hth,
B
