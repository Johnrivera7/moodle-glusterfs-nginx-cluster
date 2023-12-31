# Moodle GlusterFS Nginx Cluster

Automated script for deploying a Moodle cluster with GlusterFS as the distributed file system and Nginx as the web server.

## Repository Overview

This script automates the deployment of a Moodle cluster with GlusterFS as the distributed file system and Nginx as the web server. The cluster consists of multiple Moodle nodes, and GlusterFS ensures data replication for high availability.

### Prerequisites

- Ubuntu servers for each Moodle node.
- Open ports for GlusterFS (24007, 111, 49152-49251, 2049), Nginx (80, 443), and SSH (22).
- Instances should have a valid hostname.

### Structure diagram
![image](https://github.com/Johnrivera7/moodle-glusterfs-nginx-cluster/assets/32875176/cf0c56a1-5bb0-4b0d-a2ab-0c7bdeda83e9)  

## Usage

1. Run the script on each Moodle node.
2. Configure Nginx, PHP, and Moodle settings interactively.
3. The script sets up GlusterFS for distributed file storage.
4. Follow on-screen instructions for each node.

### Notes

- This script was tested on Ubuntu 22.04 instances.
- Ensure proper firewall or security group configurations.
- The script installs the latest version of Moodle.
- Start the script on slave nodes first, then on the master node.

## Getting Started

1. Clone this repository to your local machine.
   ```bash
   git clone https://github.com/Johnrivera7/moodle-glusterfs-nginx-cluster.git
2. cd moodle-glusterfs-nginx-cluster
3. chmod u+x deploy_moodle_cluster.sh
4. ./deploy_moodle_cluster.sh
5. Follow the instructions on the screen

## Deploy


![284403267-6ee07321-7c59-4388-9564-19a3769257de](https://github.com/Johnrivera7/moodle-glusterfs-nginx-cluster/assets/32875176/327d7784-3d6f-4dcf-9dbb-b28521649564)


## Author
John Rivera González - johnriveragonzalez@gmail.com

Version
0.1.2
# Disclaimer
This script is provided as-is. Use at your own risk.

Feel free to customize the information based on your preferences and any additional details you want to include. Choose a license that aligns with how you want others to use, modify, and distribute your script.
