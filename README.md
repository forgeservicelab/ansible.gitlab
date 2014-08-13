Gitlab
======

Ansible playbook to get gitlab installed from source on a Debian system on Forge.

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
- `cas_url` - The URL of the CAS server. This variable needs to be double quoted as it needs the quotation once the template is compiled. E.g.: `"'http://url.to.cas/'"`.
- `service_email` - The admin email address.
- `gitlab_db_pass` - The password for the gitlab user on the backend database.

Other playbook variables
----------------------

The playbook takes the following variables. Typically you'd find them on the `group_vars/all.yml` file.

- `web_domain` - Read on the common role, this is the FQDN of the target machine.
- `gitlab_source` - The URL of the git repository from which to download gitlab.
- `gitlab_version` - Git tag, branch name or commit hash of gitlab to download.
- `gitlab_shell_version` - Version of gitlab-shell to install.
- `ruby_version` - Version of ruby to install.
- `git_user_name` - Name of the unix account to run gitlab with.
- `git_user_home` - Full path of the above user's home directory.
- `gitlab_db_user` - Username of the authorised backend database user.
- `gitlab_db_host` - Hostname or IP of the backend database server.
- `gitlab_db` - Name of the backend database.
- `volume_device` - Device descriptor of an additional volume for storage, e.g.: /dev/hdb1 (optional).
- `ssh_port` - Port number on which the ssh server for gitlab will listen. Defaults to 22.
