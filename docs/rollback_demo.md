# Rollback demo using National-Parks with VMs & Terraform

With the new `--update_condition track-channel` option we can now easily demo roll-back with Habitat. 

The demo is set to configure services with the `track-channel` configuration. This gives the "rollback" behavior 

```
variable "update_condition" {
  default = "track-channel"
}
```

First we need to create a bad `.hart` so we can show a failure in Automate. The health-check uses curl to check our health. We want to create a `404` error so the failure registers as critcial in Chef Automate. 

You can comment out line the code in the `init` hook that copies the National-Parks `.war` file into the correct directory. It's line 11 at the time of this creation of this readme. 

```
#NOTE comment the next line out to create/demo a bad package 
cp {{pkg.path}}/*.war {{pkg.svc_var_path}}/tc/webapps
```
Change the major package version number so you can distinguish good vs bad packages. 

Update `pkg_version=8.0.0` in your plan.sh. 

You can also create a different channel for the roll-back demo so you don't have a bad pacakge in `current` 

Upload your .hart & create the `rb_prod` channel

`hab pkg upload eric-national-parks-8.0.0-20200509192449-x86_64-linux.hart rb_prod`

To run the demo start with a working .hart, then promote the bad .hart
`hab pkg promote eric/national-parks/8.0.0/20200509192449 rb_prod`

The national-park service will upgrade & you can show the failure in the Automate Applications tab. Once you click on the failed service the right pannel will display the error log. 

"Rollback" your change by demoting the bad package. The national-parks service will downgrade back to the previous version. You can show the new package number & the systems are now healthy in Chef Automate's Application tab. 

`hab pkg demote eric/national-parks/8.0.0/20200509192449 rb_prod`

Included in the repo is Terraform code (Version `0.12`) for launching the application in AWS and Google Kubernetes Engine. Provision either AWS, GKE, or both, and then you can watch Habitat update across cloud deployments.

