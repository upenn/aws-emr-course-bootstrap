# EMR Course Template

This Cloudformation and script can be used to deploy an Elastic Map Reduce (EMR) cluster *with* an authenticated reverse proxy for access to Livy. 

** This template has been tested in AWS Academy Associate Learner Lab accounts.** It is designed for use in Learner Lab accounts, which have restricted privileges.

## Setup instructions
1. Clone this repository
2. Modify `emr-course.yml` template. Set the `Default:` value in the `BootstrapProxyScript:` parameter so that it references the URL of the bootstrap script in your repository.
3. Optionally, specify additional bootstrap scripts in the `BootstrapMasterAdditionsScript` and `BootstrapOtherAdditionsScript` default fields.
4. Commit and push updates to your repo.
5. Share the template with students.