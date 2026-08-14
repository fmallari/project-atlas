# ------------------------------------------------------------
# GitHub Actions OIDC Provider
# ------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name    = "github-actions-oidc"
    Project = "ProjectAtlas"
  }
}

# ------------------------------------------------------------
# GitHub Actions IAM Role
# ------------------------------------------------------------

resource "aws_iam_role" "github_actions" {
  name = "project-atlas-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:fmallari/project-atlas:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "project-atlas-github-actions"
    Project = "ProjectAtlas"
  }
}
# ------------------------------------------------------------
# ECR Push Policy
# ------------------------------------------------------------

resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "project-atlas-ecr-push"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ECRAuthentication"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Sid    = "ECRPushImage"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]

        Resource = aws_ecr_repository.project_atlas.arn
      }
    ]
  })
}



