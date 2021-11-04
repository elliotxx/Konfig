import base.pkg.kusion_models.kube.frontend
import base.pkg.kusion_models.kube.frontend.ingress

# The application configuration in stack will overwrite 
# the configuration with the same attribute in base.
appConfiguration = frontend.Server {
    ingresses: [
        ingress.Ingress {
            rules: [
                {
                    "host": "guestbook.kusionexamples.com",
                    "http": {
                        "paths": [
                            {
                                "backend": {
                                    "service": {
                                        "name": "frontend"
                                        "port": {
                                            "number": 80
                                        }
                                    }
                                },
                                "path": ""
                                "pathType": "Prefix"
                            }
                        ]
                    }
                }
            ]
        }
    ]
}
