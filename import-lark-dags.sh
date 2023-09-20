export AIRFLOW_VERSION=1.10.12
export PYTHON_VERSION=3.7.12
# pyenv virtualenv $PYTHON_VERSION "soliddags-1.0"
# pyenv activate "soliddags-1.0"
# export AIRFLOW_HOME=~/airflow
# # upgrade and install cryptography first to avoid unnecessary dependency conflicts
# pip install --upgrade pip
# pip install cryptography
# PYTHON_MAJOR_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
# CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_MAJOR_VERSION}.txt"
# pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
mwaaDir=$PWD
#  Get the CodeArtifact token for soliddags:
cd ../data-airflow-dags-v2/
CODEARTIFACT_AUTH_TOKEN=$(aws --region=us-east-1 codeartifact get-authorization-token --domain lark --domain-owner 509967626473 --query authorizationToken --output text)
echo "--extra-index-url https://aws:${CODEARTIFACT_AUTH_TOKEN}@lark-509967626473.d.codeartifact.us-east-1.amazonaws.com/pypi/data-eng-pypi/simple/" > codeartifact_local.txt
cd $mwaaDir
# Then copy the group of requirements files
cp ../data-airflow-dags-v2/*.txt dags
# This command will install the requirements from the file:
./mwaa-local-env test-requirements
#
mkdir dags/{config,airflow_resources,utils}
# just adjust this next path to your actual airflow repo location
# Add DAGs
for i in {config,airflow_resources,utils}; do cp -rv ../data-airflow-dags-v2/$i/* dags/$i/; done
cp -rv ../data-airflow-dags-v2/*.py dags/
