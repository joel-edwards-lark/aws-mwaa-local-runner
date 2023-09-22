#!/bin/zsh
export AIRFLOW_VERSION=1.10.12
export PYTHON_VERSION=3.7.12
LARK_AIRFLOW_DAG_BRANCH=rc-0.3
LARK_SOLIDDAGS_BRANCH=develop

mwaaDir=$PWD

# ensure you are importing the right code
cd ../data-airflow-dags-v2
git checkout $LARK_AIRFLOW_DAG_BRANCH
git pull
cd ../airflow-soliddags
git checkout $LARK_SOLIDDAGS_BRANCH
git pull

cd $mwaaDir
#  copy the group of requirements files
cp ../data-airflow-dags-v2/*.txt docker/config
cp ../airflow-soliddags/pipenv-requirements.txt docker/config

#  Get the CodeArtifact token for soliddags:
export CODEARTIFACT_AUTH_TOKEN=`aws codeartifact get-authorization-token --profile=infra --domain lark --domain-owner 509967626473 --query authorizationToken --output text`
echo "--extra-index-url https://aws:${CODEARTIFACT_AUTH_TOKEN}@lark-509967626473.d.codeartifact.us-east-1.amazonaws.com/pypi/data-eng-pypi/simple/" > docker/config/codeartifact_local.txt

# This command will install the requirements from the file:
mkdir dags/{config,airflow_resources,utils}
# just adjust this next path to your actual airflow repo location
# Add DAGs
for i in {config,airflow_resources,utils}; do cp -rv ../data-airflow-dags-v2/$i/* dags/$i/; done
cp -rv ../data-airflow-dags-v2/*.py dags/

# Add soliddags and its dependencies
# remove if once soliddag module install works.
cp -rv ../airflow-soliddags/src/soliddags dags/
sed -i '' '1i\
-r ./pipenv-requirements.txt
' docker/config/requirements-local.txt
sed -i '' '/soliddags/d' docker/config/requirements-local.txt
sed -i '' '/soliddags/d' docker/config/requirements.txt


