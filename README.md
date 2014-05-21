Gitlab
======

Ansible playbook to get gitlab installed from source on a Debian system

Prerequisites
-------------

- The target machine(s) have to be already instantiated, this playbook does not launch computing instances
- If the source repositories use the ssh transport (default yes) with a password protected key, the following lines must appear in your ansible configuration files:

```
[ssh_connection]
ssh_args = -o ForwardAgent=yes
```

### The inventory file
This playbook targets all machines so it is **highly advised** to create a custom inventory file for this playbook and run as:

    $ ansible-playbook -i inventory gitlab.yml 

### The Secrets file
This playbook requires a number of variables that are confidential and as such not distributed with the playbook. They are expected on the `group_vars/secrets.yml` file, the variables are:

- `redmine_api_key` - The REST API key of a Redmine administrator account to be able to resolve issues on commit message keyword triggers.
- `ldap_host` - The IP or FQDN of the LDAP server.
- `ldap_port` - The port number of the LDAP server.
- `ldap_bind_dn` - The full dn of the user to bind to the LDAP server.
- `ldap_bind_pw` - The password of the bind user.
- `ldap_search_base` - The LDAP base where we can search for users
- `ldap_user_filter` - The filter (as per RFC 4515) to apply to LDAP users (this blacklists matches).
- `ldap_group_filter` - The **List** of allowed LDAP groups (this whitelists matches).
- `cas_url` - The URL of the CAS server. This variable needs to be double quoted as it needs the quotation once the template is compiled. E.g.: `"'http://url.to.cas/'"`
- `service_email` - The admin email address
