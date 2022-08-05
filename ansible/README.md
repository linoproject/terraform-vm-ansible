## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.ansible_depends](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ansible_file](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.roles](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_depends"></a> [ansible\_depends](#input\_ansible\_depends) | Check for complete run of ansible playbook with file <ansible\_confi\_done>.yaml.done | <pre>map(object({<br>        ansible_config_done = string<br>    }))</pre> | `{}` | no |
| <a name="input_ansible_roles"></a> [ansible\_roles](#input\_ansible\_roles) | n/a | <pre>map(object({<br>        rolename = string<br>    }))</pre> | `{}` | no |
| <a name="input_file_path"></a> [file\_path](#input\_file\_path) | n/a | `string` | n/a | yes |
| <a name="input_ip"></a> [ip](#input\_ip) | n/a | `string` | n/a | yes |
| <a name="input_rsa_key_path"></a> [rsa\_key\_path](#input\_rsa\_key\_path) | n/a | `string` | n/a | yes |
| <a name="input_user"></a> [user](#input\_user) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
