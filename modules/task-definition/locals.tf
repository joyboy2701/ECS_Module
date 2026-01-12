locals {
  secret_names = distinct(flatten([
    for _, container in var.container_definitions : [
      for s in container.secrets :
      split(":", s.valueFrom)[0]
    ]
  ]))
}
locals {
  secret_arn_map = {
    for name, s in data.aws_secretsmanager_secret.this :
    name => s.arn
  }
}
locals {
  resolved_container_definitions = {
    for cname, container in var.container_definitions :
    cname => merge(container, {
      secrets = [
        for s in container.secrets : {
          name = s.name
          valueFrom = format(
            "%s:%s::",
            local.secret_arn_map[split(":", s.valueFrom)[0]],
            split(":", s.valueFrom)[1]
          )
        }
      ]
    })
  }
}