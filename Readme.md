# EMR Course Template

This Cloudformation and script can be used to deploy an Elastic Map Reduce (EMR) cluster *with* an authenticated reverse proxy for access to Livy. 

** This template has been tested in AWS Academy Associate Learner Lab accounts.** It is designed for use in Learner Lab accounts, which have restricted privileges.

## Setup instructions
1. Clone this repository
2. Modify `emr-course.yml` template. Set the `Default:` value in the `BootstrapProxyScript:` parameter so that it references the URL of the bootstrap script in your repository.
3. Optionally, specify additional bootstrap scripts in the `BootstrapMasterAdditionsScript` and `BootstrapOtherAdditionsScript` default fields.
4. Commit and push updates to your repo.
5. Share the template with students.

## Stack Creation Instructions
1. After logging into your AWS account, go to the AWS CloudFormation Console: https://console.aws.amazon.com/cloudformation
2. Click the **Create Stack** Button and select **with new resources (standard)**
3. In the **Specify template** section, select **Upload a template file** and upload the `emr-course.yml` template that was published to your repository. Click Next.
4. Under **Stack name** enter `emr-course` (or another descriptive name)
5. Under Parameters, pre-populated fields can be left as-is but you must select a VpcId, VPC Public Subnet, and existing EC2 Key Pair. Additionally, enter a Username and Password that will be used to authenticate to the Livy Proxy. Click **Next**.
6. On the **Configure stack options** page, leave defaults as-is. Scroll to the bottom and click **Next**.
7. Scroll to the bottom of the **Review** page, select the checkbox acknowledgement in the **Capabilities** section at the bottom, then click **Create stack**
8. Monitor the stack for any errors during creation. When the stack status changes to `CREATE_COMPLETE` you can select the **Outputs** tab in the stack details to retrieve the DNS address of the master node. Clicking this URL should prompt for the Livy credentials. 
    
    Note: If the request times out, wait up to 5 minutes and try again. The EMR Step that configures the proxy might not have executed yet.

## Troubleshooting
- In the EMR Console (https://console.aws.amazon.com/elasticmapreduce), go to the cluster and select the **Steps** tab. Verify that the BootstrapLivyProxy step completed. If not, review the logs.
