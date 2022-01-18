import base.pkg.kusion_models.kube.frontend
import base.pkg.kusion_models.kube.frontend.container
import base.pkg.kusion_models.kube.templates.resource as res_tpl

# Main Container Configuration
_main = container.Main {
    name: "php-redis"
    env: [
        {
            name: "GET_HOSTS_FROM"
            value: "dns"
        }
    ]
    ports: [
        {
            containerPort: 80
        }
    ]
}

# Application Configuration
appConfiguration = frontend.Server {
    mainContainer: _main
    selector: {
        "tier": "frontend"
    }
    podMetadata: {
        labels: {
            "tier": "frontend"
        }
    }
    schedulingStrategy: {
        resource = res_tpl.medium
    }
}
