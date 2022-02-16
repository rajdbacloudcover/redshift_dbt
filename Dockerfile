# syntax=docker/dockerfile:1

# python image

FROM python:3.8.5


# adding our dbt project
ADD redshift_dbt /redshift_dbt
# Update and install system packages
RUN apt-get update -y && \
  apt-get install --no-install-recommends -y -q \
  git libpq-dev python-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install DBT
RUN pip install -U pip
RUN pip install dbt-redshift
#RUN pip install dbt==0.20.2

# create .dbt folder with profiles.yml file
RUN mkdir ~/.dbt
RUN cp /coinswitch-datalake-dbt/.dbt/profiles.yml ~/.dbt/
RUN cp /profiles.yml ~/.dbt/

#Setup the Environment for dbt password retrieval from AWS Secrets Manager
RUN apt-get update -y && apt-get install jq -y && apt-get install awscli -y
RUN secret=$(aws secretsmanager get-secret-value --secret-id prod/dbt/Redshift --output json  | jq '.SecretString' -r)
RUN password=$(echo $secret | jq '.password' -r)
RUN export PASSWORD=$password


# move to project dir
WORKDIR /redshift_dbt

# running dbt project
#CMD dbt run

