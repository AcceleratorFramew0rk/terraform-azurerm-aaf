# Navigate to the working directory where the Terraform configuration files are located
cd /tf/avm/templates/landingzone/configuration/2-solution_accelerators/project/ai_foundry


# Run the Custom Terraform initialization script "terraform-init-custom" at location "/usr/local/bin" to set up the backend and providers
terraform-init-custom

# Generate an execution plan to preview the changes Terraform will make
terraform plan

# Apply the Terraform configuration and automatically approve changes without prompting for confirmation
terraform apply -auto-approve