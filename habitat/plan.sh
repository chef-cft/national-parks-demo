pkg_name=national-parks
pkg_description="A sample JavaEE Web app deployed in the Tomcat8 package"
pkg_origin=ericheiser
pkg_version=7.0.0
pkg_maintainer="Eric Heiser <eheiser@chef.io>"
pkg_license=('Apache-2.0')
pkg_deps=(core/tomcat8 core/corretto8 core/mongo-tools)
pkg_build_deps=(core/corretto8 core/maven)
pkg_svc_user="root"
pkg_binds=(
  [database]="port"
)
pkg_exports=(
  [port]=server.port
)
pkg_exposes=(port)

do_prepare()
{
    export JAVA_HOME=$(hab pkg path core/corretto8)
}

do_build()
{
    cp -r $PLAN_CONTEXT/../ $HAB_CACHE_SRC_PATH/$pkg_dirname
    cd ${HAB_CACHE_SRC_PATH}/${pkg_dirname}
    mvn package
}

do_install()
{
    cp ${HAB_CACHE_SRC_PATH}/${pkg_dirname}/target/${pkg_name}.war ${PREFIX}/
    cp -v ${HAB_CACHE_SRC_PATH}/${pkg_dirname}/data/national-parks.json ${PREFIX}/
}
