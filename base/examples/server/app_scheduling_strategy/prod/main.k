import base.pkg.kusion_models.kube.frontend

# The application configuration in stack will overwrite 
# the configuration with the same attribute in base.
appConfiguration = frontend.Server {
    schedulingStrategy: {
        resource: "1<cpu<2,1Gi<memory<2Gi,disk=30Gi"
    }
}
