# Q4 — Screenshots

Visual walkthrough of this exercise, from pipeline run through a local targeted destroy of just the EC2 instance.

### 1. Pipeline

<img width="1910" height="690" alt="image" src="https://github.com/user-attachments/assets/ad651fe4-c447-4ca7-8a86-6f95d98d409d" />

---

### 2. EC2 Instance

<img width="2518" height="1186" alt="image" src="https://github.com/user-attachments/assets/6a3e9083-6787-4c42-9e82-3868b70c3cee" />

---

### 3. S3

<img width="2552" height="601" alt="image" src="https://github.com/user-attachments/assets/6c7eeca4-36b6-43b9-bbfb-ee8b1b6c303a" />

---

### 4. Target EC2 Delete from the Local

<img width="1373" height="644" alt="image" src="https://github.com/user-attachments/assets/57114724-0969-403a-af58-5df861c6863d" />

<img width="1167" height="724" alt="image" src="https://github.com/user-attachments/assets/296a2e2f-9ea4-4297-9cae-7c0930fb5972" />

<img width="1586" height="548" alt="image" src="https://github.com/user-attachments/assets/819a0179-9874-4f66-acde-96bb66b8f350" />

<img width="1763" height="729" alt="image" src="https://github.com/user-attachments/assets/720bcc95-feef-4523-949e-a5ea91ca4ef2" />

<img width="2544" height="553" alt="image" src="https://github.com/user-attachments/assets/0a9ef928-5856-489b-8db7-f350ba862d3b" />

---

### 5. Terraform State List

```bash
PS D:\Study\Terraform2\Terraform_Practise\16.Practise_Sets\Q4> terraform state list
data.aws_availability_zones.available
data.aws_caller_identity.current
aws_s3_bucket.ec2-s3-bucket
random_shuffle.az
random_string.suffix
```

---

### 6. Destroy Stage

<img width="1906" height="858" alt="image" src="https://github.com/user-attachments/assets/4e333894-d77b-4318-91c1-1dd74e8cc368" />

<img width="1898" height="564" alt="image" src="https://github.com/user-attachments/assets/2c242d34-fe4f-47c5-b536-a507fd6b4350" />
