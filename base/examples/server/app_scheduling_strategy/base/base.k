import base.pkg.kusion_models.kube.frontend
import base.pkg.kusion_models.kube.frontend.container
import base.pkg.kusion_models.kube.frontend.volume as v

# Main Container Configuration
_main = container.Main {}

# Application Configuration
appConfiguration = frontend.Server {
    mainContainer: _main
    image: "gcr.io/google-samples/gb-frontend:v4"
}
