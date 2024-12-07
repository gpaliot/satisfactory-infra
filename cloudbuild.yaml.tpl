steps:
  - name: "hashicorp/terraform:light"
    args:
      - "init"
      - "-backend-config=bucket=${bucket_name}"
      - "-backend-config=prefix=${state_prefix}"
      - "-chdir=${terraform_subdir}"

  - name: "hashicorp/terraform:light"
    args:
      - "-chdir=${terraform_subdir}"
      - "plan"
      - "-out=plan.tfplan"

  - name: "hashicorp/terraform:light"
    args:
      - "-chdir=${terraform_subdir}"
      - "apply"
      - "-auto-approve"
      - "plan.tfplan"

timeout: "1200s"

options:
  logging: CLOUD_LOGGING_ONLY