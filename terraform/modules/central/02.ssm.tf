locals {
  wrapper_script_raw = file("${path.module}/wrapper.sh")
  wrapper_script     = replace(replace(local.wrapper_script_raw, "#!/usr/bin/env bash", ""), "set -eu -o pipefail", "")
}

resource "aws_ssm_document" "this" {
  name            = var.name
  document_format = "YAML"
  document_type   = "Command"
  content = templatefile("${path.module}/ssm.document.yaml", {
    script    = trimspace(local.wrapper_script)
    s3_bucket = var.s3_bucket_name
  })

  tags = var.tags
}
