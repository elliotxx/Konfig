import base.pkg.kusion_kubernetes.api.apps.v1 as apps

demo = apps.Deployment {
	metadata: {
		name: "demo"
	}
	spec: {
		replicas: 1
		selector: {
			matchLabels: {
				"version": "v1"
			}
		}
		template: {
			spec: {
				containers: [
					{
						name: "demo"
						image: "demo-image"
					}
				]
			}
		}
	}
}