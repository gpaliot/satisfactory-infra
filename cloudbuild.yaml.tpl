steps:
  - name: "hashicorp/terraform:light"
    args:
      - "init"
      - "-backend-config=bucket=${bucket_name}"
      - "-backend-config=prefix=${state_prefix}"
      - "-chdir=${terraform_subdir}"

  - name: "hashicorp/terraform:light"
    args:
      - "plan"
      - "-out=plan.tfplan"
      - "-chdir=${terraform_subdir}"

  - name: "hashicorp/terraform:light"
    args:
      - "apply"
      - "-auto-approve"
      - "plan.tfplan"
      - "-chdir=${terraform_subdir}"

timeout: "1200s"
