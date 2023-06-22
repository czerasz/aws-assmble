data "aws_iam_policy_document" "org" {
  statement {
    sid = "AllowAccessToWholeOU"

    actions = ["s3:*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      module.releases.s3_bucket_arn,
      "${module.releases.s3_bucket_arn}/*",
    ]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values = [
        var.organization_path,
      ]
    }

    condition {
      test     = "BoolIfExists"
      variable = "aws:PrincipalIsAWSService"
      values = [
        "false"
      ]
    }
  }
}

module "releases" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v3.14.0"

  bucket_prefix = "assmble-"

  attach_deny_insecure_transport_policy = true
  attach_policy                         = true
  policy                                = data.aws_iam_policy_document.org.json
}
