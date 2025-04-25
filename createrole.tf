
#using data source for ec2  as trust policy and assume role

#The policies (trust policy and inline policy) are generated using the aws_iam_policy_document data source, which provides a more flexible way to define policies in a structured manner.

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}



# code to create iam role with ec2 as trust policy embedded to role

resource "aws_iam_role" "ec2_role" {


  name               = "ec2-access-s3-role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json


}

# create an inline policy for iam role
#aws_iam_role_policy: Creates an inline policy (example-inline-policy) for the example-role. 
#This policy allows actions like s3:ListBucket and s3:PutObject on the my-bucket S3 bucket.

resource "aws_iam_role_policy" "s3inline_policy" {
  name   = "s3-inline-policy-for-ec2-role"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.s3_inline.json


}

#using data source 


data "aws_iam_policy_document" "s3_inline" {

  statement {

    actions   = ["s3:ListBucket", "s3:PutObject"]
    resources = ["arn:aws:s3:::awsiamroles6april", "arn:aws:s3:::awsiamroles6april/*"]
  }

}



#create instance profile

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-access-s3-instance-profile"
  role = aws_iam_role.ec2_role.name
}

#getting outputs

output "role_name" {

  value = aws_iam_role.ec2_role.name

}

output "role_arn" {
  value = aws_iam_role.ec2_role.arn

}
