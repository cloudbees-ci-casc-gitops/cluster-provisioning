# Example: ./clenaup.sh -p core-workshop -h staging -n cbci -c casc-gitops-pink
# prod example: ./cleanup.sh -p core-workshop -h production -n cbci -c casc-gitops-lime


PROJECT_ID=core-workshop
DEPLOY_ENV=staging
NAMESPACE=cbci
CLUSTER_NAME=casc-gitops-blue

while getopts ":p:h:n:c:" option; do
   case $option in
      p) # gcp project id
         PROJECT_ID=${OPTARG};;
      h) # cbci deployment environment target - staging or production
         DEPLOY_ENV=${OPTARG};;
      n) # cbci namespace
         NAMESPACE=${OPTARG};;
      c) # GKE cluster name
         CLUSTER_NAME=${OPTARG};;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

echo "PROJECT_ID = ${PROJECT_ID}"
echo "DEPLOY_ENV = ${DEPLOY_ENV}"
echo "NAMESPACE = ${NAMESPACE}"
echo "CLUSTER_NAME = ${CLUSTER_NAME}"

HOST_PREFIX=""
if [ "$DEPLOY_ENV" != "production" ]; then
  HOST_PREFIX="${DEPLOY_ENV}-"
fi
echo "HOST_PREFIX = $HOST_PREFIX"

# CBCI_HOSTNAME="staging-casc-gitops.cloudbees-ci.cb-sa.io"
# PROD CBCI_HOSTNAME="casc-gitops.cloudbees-ci.cb-sa.io"
CBCI_HOSTNAME="${HOST_PREFIX}casc-gitops.cloudbees-ci.cb-sa.io"
DNS_ZONE=cloudbees-ci-cb-sa

echo "CBCI_HOSTNAME = $CBCI_HOSTNAME"

echo "getting credentials"
gcloud container clusters get-credentials $CLUSTER_NAME --project $PROJECT_ID --region us-east1
echo "deleting controller namespace"
kubectl delete namespace controllers
echo "deleting $NAMESPACE namespace"
kubectl delete namespace $NAMESPACE
echo "deleting cluster"
gcloud container clusters delete $CLUSTER_NAME --quiet --project $PROJECT_ID
echo "deleting dns record for $CBCI_HOSTNAME"
gcloud dns record-sets delete $CBCI_HOSTNAME. --type=A --zone=$DNS_ZONE --project $PROJECT_ID