data "aws_iam_role" "project_atlas_ec2" {
  name = "projectatlas-ec2role"
}

resource "aws_iam_role_policy" "project_atlas_ecr_pull" {
  name = "project-atlas-ecr-pull"
  role = data.aws_iam_role.project_atlas_ec2.name

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
        Sid    = "ECRReadProjectAtlas"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories"
        ]

        Resource = aws_ecr_repository.project_atlas.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "project_atlas_ssm" {
  role       = data.aws_iam_role.project_atlas_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
