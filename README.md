A Golang API deployed on AWS to track visitor data on my website. As well as a website to show the date and time and ip address of each site visit.

The website is deployed on a EC2 instance on a public subnet where it's hosting the website showing visit data - https://visit.mattmazer.dev
It fetches all data from the containerised api and Postgres database in a private subnet sitting behind a NAT gateway. All post requests from my site https://mattmazer.dev are proxied using NGINX from the frontend server to the server running the api. DNS records are handled on CloudFlare.

Github actions is used for the CI/CD pipeline which runs tests, builds and pushes the docker image to DockerHub and runs Terraform scripts to provision the infrastructure as well as Ansible playbooks to configure the infrastructure

Architecture diagram - https://imgur.com/a/FEKv90t
