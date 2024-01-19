# Cloud buildings


## TODO

1. Improve Depends structure with:
https://fastapi.tiangolo.com/tutorial/dependencies/dependencies-with-yield/#using-context-managers-in-dependencies-with-yield


## DEV

### Create

```bash
docker-compose build && docker-compose up -d
```

### Delete

```bash
docker-compose down
```

## PROD

### REST API backend (1st step)

#### AWS with Lambda

<details>

##### Create

```bash
cd rest_api

terraform init
terraform apply
```

##### Destroy

```bash
cd rest_api
terraform destroy
```

</details>

#### AWS with ECS & ECR

<details>

##### Create


```bash
cd rest_api

terraform init
# change aws_account_id with your account id
terraform apply -var "aws_account_id=$aws_account_id"
```

##### Destroy

```bash
cd rest_api
terraform destroy -var "aws_account_id=$aws_account_id"
```

</details>


### Lambda + S3 + CloudFront frontend (2nd step)

<details>

#### Create

```bash
cd ./frontend
npx nuxt build

sam validate
sam validate --lint

cd infrastructure/aws-lambda/step1
# read next 5 lines before executing sam deploy
sam deploy --guided
# during the deployment, after the S3 bucket is created
# but before CloudFront is deployed, run this:
aws s3 sync .output/public s3://<your_s3_bucket_name> --cache-control max-age=31536000 --delete

cd ../step2
# modify on /frontend/nuxt.config.ts cdnURL
npx nuxt build
sam deploy --guided --template-file step2.yaml
```


> For Lambda deployment, you will need to create an Internet Gateway & connect it to the VPC, and a routing table on that VPC with an entry 0.0.0.0/0 internet gateway. 
- Create EC2 in the same vpc (check assign public IP + create a security group in the VPC with port 22 open).
- Then select instance, Network, associate to RDS and choose the running RDS.
- Connect to the instance using Instance Connect (create an EIC endpoint). On the host:
```bash
scp -i "lami_pair.pem" ~/Cloud_buildings/rest_api/code/utils/insert_db2.sql ubuntu@13.49.70.29:/home/ubuntu
```
- Inside the created EC2 (you can connect using the AWS management console on the browser):
```bash
sudo apt-get install -y postgresql-client net-tools
ifconfig
psql -h my-db-instance.ckj37kdk9y49.eu-north-1.rds.amazonaws.com -U postgres -d test_db -a -f insert_db2.sql
```
- Now delete the EC2
> In lambda, delete as weel the routing table entry 0.0.0.0/0, the EIC endpoint and the internet gateway.


#### Delete

In the AWS console, go to the S3 bucket and delete all of the objects. Then:
```bash
cd /frontend/infrastructure/aws-lambda/step2
sam delete
cd ../step1
sam delete
```


</details>
