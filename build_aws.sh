if [[ $1 == "" ]]; then
    echo "Specify version number as first argument"
    exit 1
fi

if [[ $2 == "" ]]; then
    echo "Specify AWS account number as second argument"
    exit 1
fi

MORPHEUS_VERSION=$1
source ./versions.sh

cd base_ami_build
packer build -var "morpheus_version=$1" -var "aws_owner_id=$2" .
