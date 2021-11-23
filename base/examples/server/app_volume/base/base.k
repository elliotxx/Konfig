import base.pkg.kusion_models.kube.frontend
import base.pkg.kusion_models.kube.frontend.container
import base.pkg.kusion_models.kube.templates.resource as res_tpl

# Main Container Configuration
_main = container.Main {}

# Application Configuration
appConfiguration = frontend.Server {
    mainContainer: _main
    resource: res_tpl.tiny
    image: "gcr.io/google-samples/gb-frontend:v4"
}
