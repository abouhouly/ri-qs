#
## Q2
# this is in answer to Q2 to include ECR policy for deleting
# images older than 60 days but the last 20 images are kept regardless
# so the role for keeping 2 images has higher priority
#

resource "aws_ecr_repository" "houly_ecr_repo" {
  name = "houly_ecr_repo5"
}

resource "aws_ecr_lifecycle_policy" "houly_ecr_lifecycle_policy" {
repository = "${aws_ecr_repository.houly_ecr_repo.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 20 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countUnit": "days",
                "countNumber": 20
            },
            "action": {
                "type": "expire"
            }
        },
        {
        "rulePriority": 2,
        "description": "remove images older than 60",
        "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": "any",
            "countType": "sinceImagePushed",
            "countNumber": 60,
            "countUnit": "days"
        },
        "action": {
            "type": "expire"
        }
    }
    ]
}
EOF
}
