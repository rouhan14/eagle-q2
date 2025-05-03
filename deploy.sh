# Exit on error
set -e

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create one from .env.example"
    exit 1
fi

# Check if Groq API key is set
if ! grep -q "GROQ_API_KEY" .env || grep -q "GROQ_API_KEY=your_groq_api_key_here" .env; then
    echo "Error: GROQ_API_KEY not properly set in .env file"
    exit 1
fi

# Create a deployment package
echo "Creating deployment package..."
mkdir -p deployment
zip -r deployment/transcript-summarizer.zip app.py requirements.txt templates/ .env

# Check if using Terraform
if [ "$1" == "--terraform" ]; then
    # Check if terraform directory exists
    if [ ! -d "terraform" ]; then
        echo "Error: terraform directory not found"
        exit 1
    fi
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform/terraform.tfvars" ]; then
        echo "Error: terraform/terraform.tfvars not found. Please create one from terraform.tfvars.example"
        exit 1
    fi
    
    echo "Deploying with Terraform..."
    cd terraform
    terraform init
    terraform apply -auto-approve
    
    echo "Deployment complete! Check the AWS Elastic Beanstalk console for details."
    echo "Application URL:"
    terraform output application_url
else
    echo "Deployment package created at deployment/transcript-summarizer.zip"
    echo "You can now manually upload this package to your web server or cloud provider."
    echo ""
    echo "For Terraform deployment, run:"
    echo "./deploy.sh --terraform"
fi