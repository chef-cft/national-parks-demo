# Detect, Correct, Automate - Effortless Automaton Demo

This directory contains some minimal terraform capible of spinning up 1-n linux servers (defined in a `node_count` variable in `terraform.tfvars`) on which we can apply some simple detect & correct content.

## Usage

### Before you begin

This project is designed to work with Terraform >= 0.12.

Before you launch any servers, you must decide whether or not you wish to launch a Chef Automate instance. Running Chef Automate is optional, but recommended.

To run **without** a Chef Automate server:
- Ensure the `event-stream-enabled` parameter is set to `false` in your `terraform.tfvars` file.

To run **with** a Chef Automate server:
- First launch a Chef Automate instance (this can be done with the tf plan found in `../../chef-automate/aws`). Save the output variables once complete.
- Ensure the `event-stream-enabled` parameter is set to `false` in your `terraform.tfvars` file.
- Ensure the `automate_hostname`, `automate_url`, `automate_ip`, and `automate_token` are set with the proper information (NOTE: `automate_ip` refers to the public IP of the automate server)
- Set the `node_count` variable to your prefered number of nodes.

### OPTIONAL: Define your detect/correct Chef Habitat artifacts

I have created two packages to run through content quickly & easily:
- `nrycar/dca-audit`: Identical to the audit-baseline package, but without the patching scan
- `nrycar/dca-hardening`: As above for config-baseline, skips the yum update to make things speedy

If this serves your purposes, you don't need to make any changes to `terraform.tfvars`. However, the origin and package are configurable, so long as they're publicly available on `bldr.habitat.sh`. If you'd like to substitute an effortless package of your own, it's supported! Just make sure you test it ahead of time.

### Launch your server(s)

Once your `terraform.tfvars` has been updated with the above variables, and your usual keys & tags, you should now be able to run `terraform apply`

### Running the demo

Once your instances are provisioned, you can run a Detect/Correct/Automate motnion via some shell scripts provided in the ./scripts/ directory.

All scripts will use the SSH information provided in your local SSH config, or optionally you can pass the path to your ssh key of choice as a parameter like so:
`./scripts/detect.sh ~/.ssh/my_ssh_key.pem`

To run through the demo narrative, there are three scripts you'll be using:

- `./scripts/detect.sh`: Loads the audit package, and sends the output to Chef Automate
- `./scripts/waivers.sh`: Loads `waivers.toml` from `/.effortless_dca/files/` and applies it to the running audit package. By default, sets up a wavier for the `sysctl-14` and `os-08` controls (inhereted from the `linux-baseline` profile).
- `./scripts/correct.sh`: Loads the infra package as above. Takes ~30-60 seconds for results and audits to show up in Automate by default.

### Re-Running the demo

The easiest way to re-run the demo after running through the correct step is to spin everything down and back up (`terraform destroy` followed by a `terraform apply`).

Your old instances will still show up in Automate, but will go stale at whatever setting you have for missing nodes in your automate config (default: 1 day). If you have the EAS dashboard enabled, you'll also see those instances show up as "disconnected" in fairly short order once they're spun down.

## Under the hood

### Terraform Plans

The terraform is pretty lightweight and straightforward. The code is largely ripped from the national-parks instances with a few differences:

- Chef Habitat and Chef Infra Client are pre-installed to ensure the included shell scripts execute quickly
- The effortless audit/infra packages are installed (again for speed), but not loaded. This ensures no data shows up in Chef Automate until you're ready for it to.

### The effortless_dca cookbook

The cookbook has been kept very simple for ease of use and readability. The bulk of the content is handed via simple execute blocks with guards to load the appropriate hab packages if they're not already loaded like so:

```
execute 'Run Audits' do
  command "hab svc load #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
  action :run
  not_if "hab sup status #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
end
```

### The shell scripts

The shell scripts are all using a combination of `chef-run` with the outputs of your `terraform apply` to ensure that no matter how many nodes you spin up, you can run the dca audits on the lot of them. The commands all run some form of:

`chef-run ``terraform output dca_public_ips`` effortless_dca::correct --user centos`

While the number of nodes is arbitrary, please note that chef-run will perform updates in parallel from your local machine. This shouldn't make much difference with default settings, but if you run a custom cookbook that needs to transfer any large files/binaries, you may see slowdown with higher numbers of nodes.