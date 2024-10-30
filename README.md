# gcp_flask_server

### Details
This is a simple web application with terraform stack to deploy it on GCP.
* Frontend: HTML
* Backend: Python, Flask
* Database: MySQL
* IaC: Terraform

### Steps to deploy
1. Login to the GCP account.
2. Install GCP sdk or manually create and initate a project.
3. Modify terrform file with correct project ID and region.
4. Run "terraform init" and "terraform plan" if everything is according to as plan hit "terraform run".

### Brief about architectire
* Terraform creates a vpc newtork with a private and public subnet.
* Database exist in the same vpc network in a private subnet connection.
* All the static HTML files are uploaded in the GCP storage bucket.
* The flask server and config (yaml) file are uploaded in another GCP storage bucket.
* Final application is hosted on Google app engine taking the python code and config file from bucket.

### Description of the web app
* Welcome page, simple UI with the link to redirect to form page.
* Form page, 
  * Form to enter the information (name, birthday and email).
  * Submit button, to add the entered information to Database.
  * Get all entires button, to redirect to login page to get all the entered records.
* Login page, form to enter admin credentials to access all the entered records.
* All_entries page, 
  * Displays all the record in the database in a tabular format.
  * Back to form button, to return back to the form to enter new entries.
* Thankyou page, 
  * An acknowledge page to confirm data has been recorded.
  * Link to go back to form to form page to enter another record. 